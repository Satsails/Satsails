
# About Satsails

Satsails is a self-custodial Bitcoin and Liquid Network platform that offers non-custodial atomic swaps across Bitcoin, Lightning, and Liquid. The philosophy of Satsails is to become a platform for everything and anything Bitcoin. Many more features are coming soon!

We are committed to being open source and transparent, offering a non-custodial service.

**Everything we build is designed to be held and operated by you. We either use on-device technology or connect you to partner companies.**

## Data Collection

As part of our operations, we collect a **unique identifier** and register it on our server. This identifier is in no way related to your wallet. Additionally, we register a **public key**, which is used solely to direct your fiat payments and ensure that these payments are routed directly to your wallet.

This is the only data we ever collect.

### PIX Metadata

When using PIX for payments, the metadata includes the **CPF** and the **name** of the person. This information is stored alongside the **transaction ID (txid)**. We know that a certain CPF with a certain name bought a specific amount of **Depix**, and we store the **address** and **txid** where the currency was sent. Although, liquid network makes these transactions private, we store this information for customer support. We do not know anything about the transactions made with the currency after it leaves our platform.

## Core Dependencies

- [BDK](https://github.com/bitcoindevkit/bdk)
- [BDK-flutter](https://github.com/LtbLightning/bdk-flutter)
- [LWK](https://github.com/Blockstream/lwk)
- [LWK-dart (dart bindings)](https://github.com/SatoshiPortal/lwk-dart)
- [Boltz-rust](https://github.com/SatoshiPortal/boltz-rust)
- [Boltz-dart](https://github.com/SatoshiPortal/boltz-dart)

## Acknowledgements

- Special thanks to **Renato 38**, **Alan Schramm**, and **Paula** for the motivation and support to create this project.
- Thanks to the entire **Bull Bitcoin** team for the libraries they created and the support they provide.
- A special thanks to **Ishi** for the great help and quick responses to our questions.

---

This addition describes the collection and storage of CPF, name, and transaction ID when using PIX.