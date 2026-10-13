import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/home/view/home_screen.dart';
import 'features/search/view/search_screen.dart';
import 'features/watchlist/bloc/watchlist_bloc.dart';
import 'features/watchlist/view/watchlist_screen.dart';

class TvMazeApp extends StatelessWidget {
  const TvMazeApp({super.key});

  /// Lets the listener below show a SnackBar on whichever screen is open.
  static final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    // One place that reports watchlist save errors for the whole app.
    return BlocListener<WatchlistBloc, WatchlistState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.status != WatchlistStatus.failure,
      listener: (context, state) {
        _messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      child: MaterialApp(
        title: 'TVMaze Shows',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        scaffoldMessengerKey: _messengerKey,
        home: const MainShell(),
      ),
    );
  }
}

/// Bottom navigation with three tabs. IndexedStack keeps each tab alive,
/// so scroll position and loaded data survive tab switches.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _selectTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const SearchScreen(),
          // "Explore Shows" on the empty watchlist jumps to the Home tab.
          WatchlistScreen(onExplore: () => _selectTab(0)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }
}
