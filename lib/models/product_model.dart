import 'package:flutter/material.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.images,
    required this.colors,
    this.rating = 0.0,
    this.isFavourite = false,
    this.isPopular = false,
    required this.title,
    required this.price,
    required this.description,
  });

  final int id;
  final String title;
  final String description;
  final List<String> images;
  final List<Color> colors;
  final double rating;
  final double price;
  final bool isFavourite;
  final bool isPopular;
}

const String productDescription =
    'Wireless Controller for PS4™ gives you what you want in your gaming from over precision control your games to sharing …';

const List<ProductModel> demoProducts = [
  ProductModel(
    id: 1,
    images: ['https://i.postimg.cc/c19zpJ6f/Image-Popular-Product-1.png'],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      Colors.white,
    ],
    title: 'Wireless Controller for PS4™',
    price: 64.99,
    description: productDescription,
    rating: 4.8,
    isFavourite: true,
    isPopular: true,
  ),
  ProductModel(
    id: 2,
    images: ['https://i.postimg.cc/CxD6nH74/Image-Popular-Product-2.png'],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      Colors.white,
    ],
    title: 'Nike Sport White - Man Pant',
    price: 50.5,
    description: productDescription,
    rating: 4.1,
    isPopular: true,
  ),
  ProductModel(
    id: 3,
    images: ['https://i.postimg.cc/1XjYwvbv/glap.png'],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      Colors.white,
    ],
    title: 'Gloves XC Omega - Polygon',
    price: 36.55,
    description: productDescription,
    rating: 4.1,
    isFavourite: true,
    isPopular: true,
  ),
  ProductModel(
    id: 4,
    images: ['https://i.postimg.cc/d1QWXMYW/Image-Popular-Product-3.png'],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      Colors.white,
    ],
    title: 'Game Controller Limited Edition',
    price: 72.4,
    description: productDescription,
    rating: 4.4,
    isPopular: true,
  ),
];
