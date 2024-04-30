import 'package:app_final/models/AppUser.dart';
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/models/Review.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/services/ThemeService.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_final/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uuid/uuid.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantData restaurant;

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => RestaurantDetailScreenState();
}

class RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  double restaurantRating = 0;
  List<UserReview> userReviews = [];
  final TextEditingController commentController = TextEditingController();
  int currentUserRating = 0;

  @override
  void initState() {
    super.initState();
    loadRestaurantData();
  }

  void loadRestaurantData() async {
    restaurantRating = widget.restaurant.data.averageRating;
    print(restaurantRating.toString());
    List<UserReview>? reviews =
        await ApiService.getUserReviews(widget.restaurant.data.id);

    setState(() {
      if (reviews != null) {
        userReviews = reviews;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ThemeService.currentTheme.background,
      appBar: AppBar(
        backgroundColor: ThemeService.currentTheme.secondary,
        title: Text(
          widget.restaurant.data.local_name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 200, // Altura fija para el carrusel de imágenes
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.restaurant.photos_urls.isEmpty
                      ? 1
                      : widget.restaurant.photos_urls.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Color del marco
                              width: 3, // Grosor del marco
                            ),
                            borderRadius: BorderRadius.circular(
                                10), // Redondez de las esquinas del marco
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                7), // Redondez de las esquinas de la imagen
                            child: Image.network(
                              widget.restaurant.photos_urls.isEmpty
                                  ? 'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/logo_recortado.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL2xvZ29fcmVjb3J0YWRvLnBuZyIsImlhdCI6MTcxMTg5NTgyOSwiZXhwIjoxNzQzNDMxODI5fQ.PHjL3dJ4NxeZS9sEQq3PM3DvjQNGi898SzaLaLEQzms&t=2024-03-31T14%3A37%3A11.716Z'
                                  : widget.restaurant.photos_urls[index],
                              fit: BoxFit.cover,
                              width: widget.restaurant.photos_urls.isEmpty
                                  ? screenWidth
                                  : screenWidth * 0.8,
                              height: 180,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.restaurant.getParsedAdress(),
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Valoración media de los usuarios:',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: RatingBar.builder(
                  initialRating: restaurantRating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 3.0),
                  itemSize: 30,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: ThemeService.currentTheme.primary,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      restaurantRating = rating;
                    });
                  },
                  ignoreGestures: true,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.restaurant.data.web_page != 'No disponible')
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.web),
                          onPressed: () async {
                            final uri =
                                Uri.parse(widget.restaurant.data.web_page!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                        const Text('Sitio web'),
                      ],
                    ),
                  if (widget.restaurant.data.telephone != 'No disponible')
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () async {
                            final uri = Uri.parse(
                                'tel:${widget.restaurant.data.telephone}');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                        const Text('Llamar'),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Comentarios de los usuarios:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userReviews.isEmpty ? 1 : userReviews.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    if (userReviews.isEmpty) {
                      return const ListTile(
                        title:
                            Text('No hay comentarios sobre este restaurante.'),
                      );
                    }

                    final Review restaurantReview = userReviews[index].review;
                    final AppUser user = userReviews[index].user;

                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(user
                                        .profileImageUrl ??
                                    'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/logo_recortado.png'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    RatingBarIndicator(
                                      rating:
                                          restaurantReview.rating?.toDouble() ??
                                              0,
                                      itemBuilder: (context, index) =>
                                          const Icon(Icons.star,
                                              color: Colors.amber),
                                      itemCount: 5,
                                      itemSize: 20.0,
                                      direction: Axis.horizontal,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(restaurantReview.comment ?? 'Sin comentario'),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Tu valoración:',
                        style: TextStyle(fontSize: 16)),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          currentUserRating = rating.toInt();
                        });
                      },
                      ignoreGestures: false,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              labelText: 'Deja tu comentario: ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (commentController.text.isNotEmpty) {
                              Review review = Review(
                                review_id: const Uuid().v4(),
                                comment: commentController.text,
                                rating: currentUserRating,
                                review_restaurant_id: widget.restaurant.data.id,
                                review_user_id:
                                    UserService.currentUser.value!.id!,
                              );
                              submitReview(review);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitReview(Review review) async {
    await ApiService.postItem(review, toJson: Review.toJson);
    final currentUser = UserService.currentUser.value;

    if (currentUser != null) {
      final newUserReview = UserReview(review, currentUser);

      setState(() {
        userReviews.insert(0, newUserReview);
        commentController.clear();
        currentUserRating = 0;
      });
    }
  }
}

class UserReview {
  final Review review;
  final AppUser user;

  UserReview(this.review, this.user);
}
