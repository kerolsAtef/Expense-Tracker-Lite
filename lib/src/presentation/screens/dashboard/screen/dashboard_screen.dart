import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injector.dart' as di;
import '../../add_expense/screen/add_expense_screen.dart';
import '../../add_expense/widgets/expense_list.dart';
import '../../add_expense/widgets/filter_tabs.dart';
import '../../add_expense/widgets/recent_expenses_header.dart';
import '../../login/controller/cubit.dart';
import '../../login/controller/state.dart';
import '../../login/login_screen/login.dart';
import '../controller/cubit.dart';
import '../controller/state.dart';
import '../widgets/summary_cards.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load dashboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().loadDashboard();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<DashboardCubit>().loadMoreExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DashboardCubit>()..loadDashboard(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
            }
          },
          child: SafeArea(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () => context.read<DashboardCubit>().refresh(),
                  color: const Color(0xFF6C5CE7),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        backgroundColor: const Color(0xFF5B6CF6),
                        elevation: 0,
                        expandedHeight: 350,
                        collapsedHeight: 56,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            children: [
                              Column(
                                children: [
                                  // Upper half (gradient)
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF5B6CF6),
                                            Color(0xFF7B70F4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Lower half (white)
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              // Foreground UI (user header & summary card)
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        BlocBuilder<AuthCubit, AuthState>(
                                          builder: (context, state) {
                                            String userName = 'User';
                                            String userEmail = '';
                                            if (state is AuthAuthenticated) {
                                              userName = state.user.name;
                                              userEmail = state.user.email;
                                            }

                                            return Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor: Colors.white,
                                                  child: Text(
                                                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                                    style: const TextStyle(
                                                      color: Color(0xFF5B6CF6),
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Good ${_getGreeting()}',
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.9),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      userName,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                              onPressed: () {
                                                // TODO: Implement notifications
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.logout, color: Colors.white),
                                              onPressed: () {
                                                _showLogoutDialog(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Add spacing before SummaryCards so it sits properly
                                ],
                              ),

                              // Summary Cards
                              if (state is DashboardLoaded)
                                Positioned(
                                  top: 120,
                                  left: 0,
                                  right: 0,
                                  child: SummaryCards(summary: state.summary),
                                ),
                            ],
                          ),
                        ),

                      ),

                      // Spacer for content below the card
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 40),
                      ),

                      // Filter Tabs
                      SliverToBoxAdapter(
                        child: FilterTabs(
                          currentFilter: state is DashboardLoaded ? state.currentFilter : null,
                          onFilterChanged: (filter) {
                            context.read<DashboardCubit>().applyFilter(filter);
                          },
                        ),
                      ),

                      // Recent Expenses Header
                      const SliverToBoxAdapter(
                        child: RecentExpensesHeader(),
                      ),

                      // Content based on state
                      if (state is DashboardLoading)
                        const SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Loading your expenses...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (state is DashboardError)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Oops! Something went wrong',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<DashboardCubit>().refresh();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C5CE7),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (state is DashboardLoaded)
                          state.recentExpenses.isEmpty
                              ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C5CE7).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: const Color(0xFF6C5CE7),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No expenses yet',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Start tracking your expenses by\ntapping the + button below',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF718096),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton.icon(
                                    onPressed: () => _navigateToAddExpense(context),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Your First Expense'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C5CE7),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : ExpenseList(
                            expenses: state.recentExpenses,
                            isLoadingMore: state is DashboardLoadingMore,
                            hasMoreExpenses: state.hasMoreExpenses,
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToAddExpense(context),
          backgroundColor: const Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Expense',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          elevation: 4,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }

  Future<void> _navigateToAddExpense(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed(
      AddExpenseScreen.routeName,
    );
    if (result == true) {
      // Refresh dashboard if expense was added
      context.read<DashboardCubit>().refresh();
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF56565),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}