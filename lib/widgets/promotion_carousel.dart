import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class PromotionCarousel extends StatelessWidget {
  final List<PromotionItem> promotions = [
    PromotionItem(
      title: "60% OFF!",
      subtitle: "On Clothes Special\nHalloween Event",
      buttonText: "Checkout Now",
      image: "assets/images/offer1.png",
      backgroundColor: Color(0xFFFFCC80), // Vibrant peach-orange
      textColor: Color(0xFF4E342E),
      accentColor: Color(0xFFFF6F00), // Deep orange
    ),
    PromotionItem(
      title: "NEW ARRIVAL",
      subtitle: "Premium Pet Food\nOrganic & Healthy",
      buttonText: "Shop Now",
      image: "assets/images/offer1.png",
      backgroundColor: Color(0xFFE0F2F1), // Mint cream
      textColor: Color(0xFF004D40),       // Deep teal
      accentColor: Color(0xFF00796B),     // Emerald-teal
    ),
    PromotionItem(
      title: "30% OFF",
      subtitle: "Pet Accessories\nLimited Time Offer",
      buttonText: "View Deals",
      image: "assets/images/offer1.png",
      backgroundColor: Color(0xFFEDE7F6), // Soft lavender
      textColor: Color(0xFF512DA8),       // Indigo
      accentColor: Color(0xFF7E57C2),     // Muted purple
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ImageSlideshow(
        width: double.infinity,
        height: 160,
        initialPage: 0,
        indicatorColor: Color(0xFFEF6C00), // Burnt orange
        indicatorBackgroundColor: Color(0xFFBCAAA4), // Muted brown
        autoPlayInterval: 4000,
        isLoop: true,
        children: promotions.map((promo) =>
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    promo.backgroundColor.withOpacity(0.95),
                    Colors.white.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promo.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: promo.textColor,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  offset: Offset(1, 1),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            promo.subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: promo.textColor.withOpacity(0.85),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              // Handle button tap
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  promo.buttonText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: promo.accentColor,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: promo.accentColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(promo.image),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ).toList(),
      ),
    );
  }
}

class PromotionItem {
  final String title;
  final String subtitle;
  final String buttonText;
  final String image;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;

  PromotionItem({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.image,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
  });
}
