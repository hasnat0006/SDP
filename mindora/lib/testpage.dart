import 'package:flutter/material.dart';
import './backend/main_query.dart';

class DatabaseTestPage extends StatelessWidget {
  const DatabaseTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Connection Test')),
      body: Center(
        child: FutureBuilder<List<dynamic>>(
          future: getFromBackend('users'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Text('No users found');
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(title: Text(user.toString()));
              },
            );
          },
        ),
      ),
    );
  }
}
