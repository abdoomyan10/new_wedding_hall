// features/home/presentation/widgets/custom_search_delegate.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';

class CustomSearchDelegate extends SearchDelegate {
  final HomeCubit cubit;

  CustomSearchDelegate({required this.cubit});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            cubit.clearSearch();
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
        cubit.clearSearch();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildQuickSuggestions();
    }

    cubit.search(query);
    return _buildSearchResults();
  }

  Widget _buildQuickSuggestions() {
    final quickSearches = [
      'حفلات هذا الأسبوع',
      'مدفوعات معلقة',
      'عملاء جدد',
      'حفلات مؤكدة',
    ];

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'بحث سريع',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...quickSearches.map((text) => ListTile(
          leading: const Icon(Icons.search),
          title: Text(text),
          onTap: () {
            query = text;
            cubit.search(text);
          },
        )),
      ],
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SearchResults) {
          final results = state.results.results;
          if (results.isEmpty) {
            return const Center(
              child: Text('لا توجد نتائج'),
            );
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                leading: _getResultIcon(result.type),
                title: Text(result.title),
                subtitle: Text(result.subtitle),
                onTap: () {
                  // التعامل مع النتيجة
                  close(context, result);
                },
              );
            },
          );
        } else if (state is SearchError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }

  Icon _getResultIcon(String type) {
    switch (type) {
      case 'event':
        return const Icon(Icons.event);
      case 'client':
        return const Icon(Icons.person);
      case 'payment':
        return const Icon(Icons.payment);
      default:
        return const Icon(Icons.search);
    }
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }
}