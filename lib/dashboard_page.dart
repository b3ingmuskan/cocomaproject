import 'package:cocoma_2/banner_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  /// 🔥 LOGOUT FUNCTION
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    /// ✅ REMOVE TOKEN
    await prefs.remove("token");

    /// ✅ NAVIGATION RESET
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).primaryColor;

    return Scaffold(

      /// ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Admin Panel"),
        actions: [

          const Icon(Icons.notifications_none),
          const SizedBox(width: 15),

          const Icon(Icons.person_outline),
          const SizedBox(width: 15),

          /// 🔥 LOGOUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text(
                        "Are you sure you want to logout?"),
                    actions: [

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),

                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // close dialog
                          await logout(context);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(width: 15),
        ],
      ),

      /// ================= DRAWER =================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            DrawerHeader(
              padding: const EdgeInsets.only(top: 25, left: 15, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [

                      Image.asset(
                        "assets/images/fly2.png",
                        height: 80,
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        "Cocoma\nStudios",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),

            /// ACTIVE MENU
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: menuItem(
                  context, Icons.dashboard_outlined, "Dashboard"),
            ),

            /// BANNERS
            menuItem(context, Icons.image_outlined, "Banners"),

            menuItem(context, Icons.design_services_outlined, "Services"),
            menuItem(context, Icons.work_outline, "Our Work"),
            menuItem(context, Icons.lightbulb_outline, "Solutions"),
            menuItem(context, Icons.article_outlined, "Blogs"),
            menuItem(context, Icons.info_outline, "About Us"),
            menuItem(context, Icons.star_border, "Highlights"),
            menuItem(context, Icons.business_outlined, "Our Clients"),
            menuItem(context, Icons.work_outline, "Careers"),
            menuItem(context, Icons.description_outlined, "Application Forms"),
            menuItem(context, Icons.call_to_action_outlined, "Call To Action"),
            menuItem(context, Icons.settings_outlined, "Setting"),
          ],
        ),
      ),

      /// ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Welcome back! Here's what's happening today.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            dashboardCard(
                "Total Services", "5", Icons.design_services),
            const SizedBox(height: 15),

            dashboardCard(
                "Portfolio Items", "5", Icons.work),
            const SizedBox(height: 15),

            dashboardCard(
                "Blog Posts", "5", Icons.article),
            const SizedBox(height: 15),

            dashboardCard(
                "Team Members", "5", Icons.people),
          ],
        ),
      ),
    );
  }

  /// ================= CARD =================
  Widget dashboardCard(
      String title, String number, IconData icon) {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8)
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                number,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "+12% from last month",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),

          Icon(icon, size: 32),
        ],
      ),
    );
  }

  /// ================= MENU =================
  static Widget menuItem(
      BuildContext context, IconData icon, String title) {

    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),

      onTap: () {
        Navigator.pop(context);

        if (title == "Banners") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BannerPage(),
            ),
          );
        }
      },
    );
  }
}