import 'package:equatable/equatable.dart';

enum OrderStatus {
  created,
  confirmed,
  inProgress,
  outForDelivery,
  delivered,
  cancelled,
}

enum PaymentMethod { cod, online }

class Order extends Equatable {
  final String id;
  final String customerId;
  final String addressText;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final double subtotalProducts;
  final double deliveryFeeTotal;
  final double discountTotal;
  final double grandTotal;
  final String? otpCode;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerId,
    required this.addressText,
    required this.paymentMethod,
    required this.status,
    required this.subtotalProducts,
    required this.deliveryFeeTotal,
    required this.discountTotal,
    required this.grandTotal,
    this.otpCode,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      addressText: json['address_text'] as String,
      paymentMethod: _paymentMethodFromString(json['payment_method'] as String),
      status: _statusFromString(json['status'] as String),
      subtotalProducts: (json['subtotal_products'] as num).toDouble(),
      deliveryFeeTotal: (json['delivery_fee_total'] as num).toDouble(),
      discountTotal: (json['discount_total'] as num).toDouble(),
      grandTotal: (json['grand_total'] as num).toDouble(),
      otpCode: json['otp_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static PaymentMethod _paymentMethodFromString(String method) {
    return method == 'COD' ? PaymentMethod.cod : PaymentMethod.online;
  }

  static OrderStatus _statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return OrderStatus.created;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'IN_PROGRESS':
        return OrderStatus.inProgress;
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.outForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.created;
    }
  }

  String get statusArabic {
    switch (status) {
      case OrderStatus.created:
        return 'تم الطلب';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.inProgress:
        return 'قيد التحضير';
      case OrderStatus.outForDelivery:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        addressText,
        paymentMethod,
        status,
        subtotalProducts,
        deliveryFeeTotal,
        discountTotal,
        grandTotal,
        otpCode,
        createdAt,
      ];
}