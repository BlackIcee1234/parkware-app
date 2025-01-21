import 'package:flutter_dotenv/flutter_dotenv.dart';


// Environment variables definition
class Environment {
  //Stripe
  static String stripePublishableKey = dotenv.env["STRIPE_PUBLISHABLE_KEY"]!;
  static String stripeSecretKey = dotenv.env["STRIPE_SECRET_KEY"]!;
  //Sanity
  static String sanityApiDataset = dotenv.env["SANITY_API_DATASET"]!;
  static String sanityApiProjectId = dotenv.env["SANITY_API_PROJECT_ID"]!;
  static String sanityApiToken = dotenv.env["SANITY_API_TOKEN"]!;
}
