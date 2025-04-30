# Ticket Trust - Decentralized Event Ticketing on Stacks

A secure and transparent event ticketing system built on the Stacks blockchain that prevents scalping through price caps and provides verifiable ownership.

## Features

- **Event Creation**: Organizers can create events with customizable parameters
  - Event name
  - Ticket price
  - Maximum ticket capacity
  
- **Secure Ticket Minting**: NFT-like tickets with verifiable ownership
  - One transaction per ticket
  - Automatic sales tracking
  - Built-in capacity limits

- **Protected Resale Market**: Anti-scalping measures
  - Maximum resale price capped at 120% of original price
  - Direct peer-to-peer transfers
  - Transparent pricing history

- **Event Management**
  - Event cancellation support
  - Manual refund processing
  - Real-time ticket availability tracking

## Smart Contract Functions

### Public Functions

```clarity
(create-event (name (string-ascii 50)) (ticket-price uint) (ticket-cap uint))
(mint-ticket (event-id uint))
(resell-ticket (ticket-id uint) (buyer principal) (price uint))
(cancel-event (event-id uint))
```

### Read-Only Functions

```clarity
(get-event (event-id uint))
(get-ticket-owner (ticket-id uint))
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/ticket-trust.git
```

2. Install dependencies:
```bash
npm install
```

3. Deploy the contract:
```bash
clarinet deploy
```

## Usage

### Creating an Event

```clarity
(contract-call? .ticket-trust create-event "Concert Name" u100 u1000)
```

### Purchasing a Ticket

```clarity
(contract-call? .ticket-trust mint-ticket u1)
```

### Reselling a Ticket

```clarity
(contract-call? .ticket-trust resell-ticket u1 'BUYER_ADDRESS u120)
```

## Development

Built with:
- Clarity Smart Contracts
- Stacks Blockchain
- Clarinet Testing Framework

## License

MIT License

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

