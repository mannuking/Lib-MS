import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:library_management_system/features/auth/services/auth_service.dart';
import 'package:library_management_system/features/auth/screens/login_screen.dart';
import 'package:library_management_system/features/auth/screens/signup_screen.dart';
import 'package:library_management_system/features/home/screens/home_screen.dart';
import 'package:library_management_system/features/books/screens/book_details_screen.dart';
import 'package:library_management_system/features/books/screens/add_book_screen.dart';
import 'package:library_management_system/features/books/screens/search_screen.dart';
import 'package:library_management_system/features/profile/screens/profile_screen.dart';
import 'package:library_management_system/features/recommendations/screens/recommendations_screen.dart';
import 'package:library_management_system/shared/widgets/main_layout.dart';

// Route names
class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String bookDetails = '/book/:id';
  static const String addBook = '/add-book';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String recommendations = '/recommendations';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.asData?.value != null;
      final isOnAuthPage = state.matchedLocation == AppRoutes.login || 
                          state.matchedLocation == AppRoutes.signup;
      
      if (!isLoggedIn && !isOnAuthPage) {
        return AppRoutes.login;
      }
      
      if (isLoggedIn && isOnAuthPage) {
        return AppRoutes.home;
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Main app routes with shell
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.recommendations,
            name: 'recommendations',
            builder: (context, state) => const RecommendationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Book details route (full screen)
      GoRoute(
        path: AppRoutes.bookDetails,
        name: 'bookDetails',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return BookDetailsScreen(bookId: bookId);
        },
      ),
      
      // Add book route (full screen)
      GoRoute(
        path: AppRoutes.addBook,
        name: 'addBook',
        builder: (context, state) => const AddBookScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
