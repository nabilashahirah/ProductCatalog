class Product {
  final int id;
  final String title;
  final String description;
  final String? brand;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String availabilityStatus;
  final String warrantyInformation;
  final String shippingInformation;
  final String returnPolicy;
  final String thumbnail;
  final List<String> images;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.title,
    required this.description,
    this.brand,
    this.category = '',
    required this.price,
    this.discountPercentage = 0,
    required this.rating,
    this.stock = 0,
    this.availabilityStatus = '',
    this.warrantyInformation = '',
    this.shippingInformation = '',
    this.returnPolicy = '',
    required this.thumbnail,
    required this.images,
    this.reviews = const [],
  });

  double? get originalPrice {
    if (discountPercentage <= 0) return null;
    return price / (1 - discountPercentage / 100);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      brand: json['brand'] as String?,
      category: json['category'] ?? '',
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      availabilityStatus: json['availabilityStatus'] ?? '',
      warrantyInformation: json['warrantyInformation'] ?? '',
      shippingInformation: json['shippingInformation'] ?? '',
      returnPolicy: json['returnPolicy'] ?? '',
      thumbnail: json['thumbnail'],
      images: List<String>.from(json['images']),
      reviews: (json['reviews'] as List?)
              ?.map((r) => Review.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class Review {
  final double rating;
  final String comment;
  final String date;
  final String reviewerName;

  Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      date: json['date'] as String,
      reviewerName: json['reviewerName'] as String,
    );
  }
}

class ProductResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  ProductResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      products: (json['products'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}

class Category {
  final String slug;
  final String name;

  Category({required this.slug, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(slug: json['slug'], name: json['name']);
  }
}
