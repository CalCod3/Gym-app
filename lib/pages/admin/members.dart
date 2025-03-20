import 'package:flutter/material.dart';
import 'package:wod_book/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch members when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final members = userProvider.members;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : members == null || members.isEmpty
              ? const Center(child: Text('No members found'))
              : ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];

                    return ListTile(
                      title: Text('${member.user.firstName} ${member.user.lastName}'),
                      subtitle: Text('Email: ${member.user.email}'),
                      trailing: Text(
                        member.hasPaid ? 'Paid' : 'Not Paid',
                        style: TextStyle(
                          color: member.hasPaid ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          ),
                      )
                    );
                  },
                ),
    );
  }
}
