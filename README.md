# 🌍 Cross-Border Remittance Router

> 💸 On-chain routing and settlement optimizer that minimizes fees and FX slippage for cheaper remittances

## 🚀 Overview

The Cross-Border Remittance Router is a smart contract built on Stacks that automatically finds the most cost-effective route for cross-border payments. By comparing multiple remittance providers in real-time, users can save significantly on fees while ensuring transparent settlement rules.

## ✨ Key Features

- 🔄 **Multi-Route Optimization** - Automatically selects the cheapest route
- 💰 **Fee Minimization** - Compares base fees and exchange rates across providers  
- 🏦 **Liquidity Management** - Track and manage route liquidity pools
- 📊 **Transparent Settlement** - All transactions recorded on-chain
- ⚡ **Real-time Rate Updates** - Dynamic exchange rate adjustments
- 🔒 **Secure Escrow** - Funds held safely during settlement

## 🛠️ Contract Functions

### 📋 Administrative Functions

#### `add-route`
Adds a new remittance route (owner only)
```clarity
(add-route "Western Union" 'SP123...ABC u1000 u250 u95000 u100 u50000)
```

#### `update-route-status` 
Enable/disable specific routes
```clarity
(update-route-status u1 false)
```

#### `update-exchange-rate`
Update exchange rates for routes
```clarity
(update-exchange-rate u1 u96500)
```

### 💳 User Functions

#### `deposit`
Deposit STX to your balance
```clarity
(deposit)
```

#### `send-remittance`
Send money through optimal route
```clarity
(send-remittance 'SP456...DEF u10000 u1)
```

#### `add-liquidity`
Add liquidity to specific routes
```clarity
(add-liquidity u1 u50000)
```

### 📊 Read-Only Functions

#### `get-optimal-route`
Find cheapest route for amount
```clarity
(get-optimal-route u10000)
```

#### `get-route`
Get route details
```clarity
(get-route u1)
```

#### `get-user-balance`
Check user balance
```clarity
(get-user-balance 'SP123...ABC)
```

## 💡 Usage Example

1. **Owner sets up routes:**
   ```clarity
   (add-route "FastTransfer" 'SP111...AAA u500 u200 u95500 u50 u100000)
   (add-route "QuickSend" 'SP222...BBB u800 u150 u95800 u100 u75000)
   ```

2. **User deposits funds:**
   ```clarity
   (deposit) ;; Deposits user's STX balance
   ```

3. **User sends remittance:**
   ```clarity
   (send-remittance 'SP333...CCC u5000 u1) ;; Send $50 via route 1
   ```

4. **System finds optimal route:**
   ```clarity
   (get-optimal-route u5000) ;; Returns cheapest route ID
   ```

5. **Owner settles transaction:**
   ```clarity
   (settle-remittance u1) ;; Marks settlement complete
   ```

## 🏗️ Contract Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User Deposit  │───▶│  Route Selection │───▶│   Settlement    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Balance Tracking│    │ Fee Calculation  │    │ Liquidity Pool  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📈 Fee Structure

- **Base Fee**: Fixed fee per transaction (varies by route)
- **Rate Fee**: Percentage of transaction amount (in basis points)  
- **Protocol Fee**: 0.5% of all transactions (configurable)

**Total Cost = Base Fee + (Amount × Rate Fee / 10000)**

## 🔧 Development Setup

```bash
# Clone repository
git clone https://github.com/gimbiyamanyar/Cross-Border-Remittance-Router.git

# Install Clarinet
npm install -g @hirosystems/clarinet-cli

# Run tests
clarinet test

# Check contract
clarinet check
```

## 🧪 Testing

```bash
# Run all tests
clarinet test

# Check contract syntax
clarinet check contracts/Cross-Border-Remittance-Router.clar

# Console testing
clarinet console
```

## 📊 Example Route Comparison

| Route | Base Fee | Rate Fee | Total Cost* | Best For |
|-------|----------|----------|-------------|----------|
| FastTransfer | 500 STX | 2.0% | 700 STX | Large amounts |
| QuickSend | 800 STX | 1.5% | 950 STX | Medium amounts |
| EcoRoute | 200 STX | 3.0% | 500 STX | Small amounts |

*Based on 10,000 STX transfer

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙋‍♂️ Support

For questions and support:
- 📧 Open an issue on GitHub
- 💬 Join our Discord community
- 📖 Check the documentation

---

Made with ❤️ for cheaper, faster cross-border payments
