(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-route (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-route-not-found (err u104))
(define-constant err-invalid-rate (err u105))

(define-data-var next-route-id uint u1)
(define-data-var protocol-fee-rate uint u50)

(define-map remittance-routes
  uint
  {
    name: (string-ascii 64),
    provider: principal,
    base-fee: uint,
    fee-rate: uint,
    exchange-rate: uint,
    min-amount: uint,
    max-amount: uint,
    is-active: bool
  }
)

(define-map user-balances
  principal
  uint
)

(define-map route-liquidity
  uint
  uint
)

(define-map pending-settlements
  uint
  {
    sender: principal,
    recipient: principal,
    amount: uint,
    route-id: uint,
    created-at: uint,
    is-settled: bool
  }
)

(define-data-var next-settlement-id uint u1)

(define-public (add-route (name (string-ascii 64)) (provider principal) (base-fee uint) (fee-rate uint) (exchange-rate uint) (min-amount uint) (max-amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> exchange-rate u0) err-invalid-rate)
    (let ((route-id (var-get next-route-id)))
      (map-set remittance-routes route-id
        {
          name: name,
          provider: provider,
          base-fee: base-fee,
          fee-rate: fee-rate,
          exchange-rate: exchange-rate,
          min-amount: min-amount,
          max-amount: max-amount,
          is-active: true
        }
      )
      (var-set next-route-id (+ route-id u1))
      (ok route-id)
    )
  )
)

(define-public (update-route-status (route-id uint) (is-active bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (match (map-get? remittance-routes route-id)
      route (begin
        (map-set remittance-routes route-id (merge route { is-active: is-active }))
        (ok true)
      )
      err-route-not-found
    )
  )
)

(define-public (update-exchange-rate (route-id uint) (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-rate u0) err-invalid-rate)
    (match (map-get? remittance-routes route-id)
      route (begin
        (map-set remittance-routes route-id (merge route { exchange-rate: new-rate }))
        (ok true)
      )
      err-route-not-found
    )
  )
)

(define-public (deposit)
  (let ((amount (stx-get-balance tx-sender)))
    (asserts! (> amount u0) err-insufficient-balance)
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (map-set user-balances tx-sender
          (+ (default-to u0 (map-get? user-balances tx-sender)) amount)
        )
        (ok amount)
      )
      error err-insufficient-balance
    )
  )
)

(define-public (send-remittance (recipient principal) (amount uint) (route-id uint))
  (let (
    (sender-balance (default-to u0 (map-get? user-balances tx-sender)))
    (route (unwrap! (map-get? remittance-routes route-id) err-route-not-found))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (get is-active route) err-invalid-route)
    (asserts! (>= amount (get min-amount route)) err-invalid-amount)
    (asserts! (<= amount (get max-amount route)) err-invalid-amount)
    (let (
      (total-fee (calculate-total-fee amount route-id))
      (required-amount (+ amount total-fee))
    )
      (asserts! (>= sender-balance required-amount) err-insufficient-balance)
      (map-set user-balances tx-sender (- sender-balance required-amount))
      (let ((settlement-id (var-get next-settlement-id)))
        (map-set pending-settlements settlement-id
          {
            sender: tx-sender,
            recipient: recipient,
            amount: amount,
            route-id: route-id,
            created-at: stacks-block-height,
            is-settled: false
          }
        )
        (var-set next-settlement-id (+ settlement-id u1))
        (ok settlement-id)
      )
    )
  )
)

(define-public (settle-remittance (settlement-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (match (map-get? pending-settlements settlement-id)
      settlement (begin
        (asserts! (not (get is-settled settlement)) err-invalid-route)
        (map-set pending-settlements settlement-id (merge settlement { is-settled: true }))
        (ok true)
      )
      err-route-not-found
    )
  )
)

(define-public (add-liquidity (route-id uint) (amount uint))
  (begin
    (asserts! (is-some (map-get? remittance-routes route-id)) err-route-not-found)
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success (begin
        (map-set route-liquidity route-id
          (+ (default-to u0 (map-get? route-liquidity route-id)) amount)
        )
        (ok amount)
      )
      error err-insufficient-balance
    )
  )
)

(define-read-only (get-optimal-route (amount uint))
  (let (
    (route-1-cost (calculate-route-cost amount u1))
    (route-2-cost (calculate-route-cost amount u2))
    (route-3-cost (calculate-route-cost amount u3))
  )
    (if (and (< route-1-cost route-2-cost) (< route-1-cost route-3-cost))
      (ok u1)
      (if (< route-2-cost route-3-cost)
        (ok u2)
        (ok u3)
      )
    )
  )
)

(define-read-only (calculate-total-fee (amount uint) (route-id uint))
  (match (map-get? remittance-routes route-id)
    route (+ (get base-fee route) (/ (* amount (get fee-rate route)) u10000))
    u0
  )
)

(define-read-only (calculate-route-cost (amount uint) (route-id uint))
  (match (map-get? remittance-routes route-id)
    route (if (get is-active route)
      (+ (get base-fee route) (/ (* amount (get fee-rate route)) u10000))
      u999999999
    )
    u999999999
  )
)

(define-read-only (get-route (route-id uint))
  (map-get? remittance-routes route-id)
)

(define-read-only (get-settlement (settlement-id uint))
  (map-get? pending-settlements settlement-id)
)

(define-read-only (get-user-balance (user principal))
  (default-to u0 (map-get? user-balances user))
)

(define-read-only (get-route-liquidity (route-id uint))
  (default-to u0 (map-get? route-liquidity route-id))
)
