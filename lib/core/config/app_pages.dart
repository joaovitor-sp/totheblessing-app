import 'package:flutter/material.dart';
import 'package:totheblessing/presentation/pages/accept_invite/accept_invite_page.dart';
import 'package:totheblessing/presentation/pages/calendar_posts/calendar_posts_page.dart';
import 'package:totheblessing/presentation/pages/create_group/create_group_page.dart';
import 'package:totheblessing/presentation/pages/edit_group/edit_group_page.dart';
import 'package:totheblessing/presentation/pages/group_details/group_details_page.dart';
import 'package:totheblessing/presentation/pages/invite/invite_page.dart';
import 'package:totheblessing/presentation/pages/list_groups/list_groups_page.dart';
import 'package:totheblessing/presentation/pages/login/login_page.dart';
import 'package:totheblessing/presentation/pages/post/post_page.dart';
import '/presentation/pages/home/home_page.dart';
import '/core/config/app_routes.dart';

class AppPages {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.listGroups:
        return MaterialPageRoute(builder: (_) => const ListGroupsPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRoutes.createGroup:
        return MaterialPageRoute(builder: (_) => const CreateGroupPage());
      case AppRoutes.calendarPosts:
        return MaterialPageRoute(builder: (_) => const CalendarPostPage());
      case AppRoutes.post:
        return MaterialPageRoute(builder: (_) => const PostPage());
      case AppRoutes.invite:
        return MaterialPageRoute(builder: (_) => const InvitePage());
      case AppRoutes.acceptInvite:
        final args = settings.arguments as Map<String, String>?;
        return MaterialPageRoute(builder: (_) => AcceptInvitePage(groupId: args?['groupId'] ?? ""));
      case AppRoutes.groupDetails:
        return MaterialPageRoute(builder: (_) => const GroupDetailsPage());
      case AppRoutes.groupEdit:
        return MaterialPageRoute(builder: (_) => const EditGroupPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}