import 'package:flutter_breez_liquid/flutter_breez_liquid.dart'; // Import your freezed error file

/// A helper function to translate Breez SDK errors into user-friendly messages.
String formatBreezError(Object error) {
  if (error is SdkError) {
    return switch (error) {
      SdkError_AlreadyStarted() => "The service has already started.",
      SdkError_NotStarted() => "The service has not been started.",
      SdkError_ServiceConnectivity(err: final msg) => "Connection error: $msg",
      SdkError_Generic(err: final msg) => "An unexpected error occurred: $msg",
    };
  }

  if (error is PaymentError) {
    return switch (error) {
      PaymentError_AlreadyClaimed() => "This payment has already been claimed.",
      PaymentError_AlreadyPaid() => "This invoice has already been paid.",
      PaymentError_PaymentInProgress() => "A payment is already in progress.",
      PaymentError_AmountOutOfRange(min: final min, max: final max) => "Amount is out of range. Min: $min, Max: $max.",
      PaymentError_InsufficientFunds() => "You have insufficient funds for this payment.",
      PaymentError_InvalidInvoice(err: final msg) => "Invalid invoice: $msg",
      PaymentError_PaymentTimeout() => "The payment timed out. Please try again.",
      PaymentError_Refunded(err: final msg, refundTxId: final id) => "Payment failed and was refunded. Reason: $msg, Refund TX: $id",
      PaymentError_Generic(err: final msg) => msg, // Use the generic message directly
      _ => "An unknown payment error occurred.", // Fallback for other PaymentError types
    };
  }

  // Fallback for any other unexpected errors
  return error.toString();
}