
# About Satsails

Satsails is a self-custodial Bitcoin and Liquid Network platform that Bitcoin, Lightning, and Liquid. The philosophy of Satsails is to become a platform for everything and anything Bitcoin. Many more features are coming soon!

We are committed to being open source and transparent, offering a non-custodial service for bitcoin and liquid.

Currently our Lightning is custodial and operated by Coinos. This was a decision made to focus on usability. News should be coming soon about other Lightning options

**Everything we build is designed to be held and operated by you. We either use on-device technology or connect you to partner companies.**

## Data Collection

As part of our operations, we collect a **unique identifier** and register it on our server to allow for account creation and managment. Additionally, we register a **public key**, which is used solely to direct your fiat payments and ensure that these payments are routed directly to your wallet.

This is the only data we ever collect on our systems.

### PIX Metadata

When using PIX for payments, the metadata includes the **CPF** and the **name** of the person. This is collected by our partners.

## Core Dependencies

- [BDK](https://github.com/bitcoindevkit/bdk)
- [BDK-flutter](https://github.com/LtbLightning/bdk-flutter)
- [LWK](https://github.com/Blockstream/lwk)
- [LWK-dart (dart bindings)](https://github.com/SatoshiPortal/lwk-dart)

## Acknowledgements

- Special thanks to **Renato 38**, **Alan Schramm**, and **Paula** for the motivation and support to create this project.
- Thanks to the entire **Bull Bitcoin** team for the libraries they created and the support they provide.
- A special thanks to **Ishi** for the great help and quick responses to our questions.

## Build Instructions

To build the Satsails application for Flutter, follow these steps:

1. **Install FVM**:
   First, install FVM by following the instructions at [FVM Installation Guide](https://fvm.app/documentation/getting-started/installation).

2. **Create a Firebase Project**:

3. **Set Up Firebase for Your Flutter App**:

4. **Clone the Repository**:
   ```bash
   git clone https://github.com/your_username/satsails.git
   cd satsails
   ```

5. **Use the Correct Flutter Version**:
   Run the following command to use the specified Flutter version:
   ```bash
   fvm use
   ```

6. **Get Dependencies**:
   Run the following command to fetch all the required dependencies:
   ```bash
   flutter pub get
   ```

7. **Create the `.env` File**:
   You need to create an `.env` file following the example provided in the `.env.sample` file. Contact Satsails to obtain the necessary values for the `.env` file at [contatosatsails@proton.me](mailto:contatosatsails@proton.me).

8. **Run the Application**:
   You can run the application on an emulator or a connected device using:
   ```bash
   flutter run
   ```

9. **Additional Build Options**:
   You can also build for iOS or other platforms. Refer to the Flutter documentation for more details on building for different platforms.

