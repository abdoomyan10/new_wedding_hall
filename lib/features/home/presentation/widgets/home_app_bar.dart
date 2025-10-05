// features/home/presentation/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import 'custom_search_delegate.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;

  const HomeAppBar({
    super.key,
    this.onSearchPressed,
    this.onNotificationsPressed,
    this.onProfilePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final homeData = state is HomeLoaded ? state.homeData : null;

        return AppBar(
          title: const Text(
            'محاسبة الأفراح',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.purple[700],
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          actions: [
            // زر البحث
            _SearchIconButton(onPressed: onSearchPressed),

            // زر الإشعارات
            _NotificationIconButton(
              unreadCount: homeData?.unreadNotificationsCount ?? 0,
              onPressed: onNotificationsPressed,
            ),

            // زر الملف الشخصي
            _ProfileIconButton(
              userName: homeData?.userName ?? 'مستخدم',
              imageUrl: homeData?.userImageUrl,
              onPressed: onProfilePressed,
            ),

            const SizedBox(width: 8),
          ],
        );
      },
    );
  }
}

// ويدجت زر البحث المعزول
class _SearchIconButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SearchIconButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search, size: 25),
      onPressed: onPressed ?? () {
        showSearch(
          context: context,
          delegate: CustomSearchDelegate(
            cubit: context.read<HomeCubit>(),
          ),
        );
      },
      tooltip: 'بحث',
    );
  }
}

// ويدجت زر الإشعارات المعزول
class _NotificationIconButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onPressed;

  const _NotificationIconButton({
    required this.unreadCount,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 25),
          onPressed: onPressed,
          tooltip: 'الإشعارات',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// ويدجت زر الملف الشخصي المعزول
class _ProfileIconButton extends StatelessWidget {
  final String userName;
  final String? imageUrl;
  final VoidCallback? onPressed;

  const _ProfileIconButton({
    required this.userName,
    this.imageUrl,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onPressed,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withOpacity(0.3),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null ?
          const Icon(Icons.person, color: Colors.white, size: 20) : null,
        ),
      ),
    );
  }
}