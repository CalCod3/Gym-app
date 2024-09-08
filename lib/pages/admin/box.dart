import 'package:fit_nivel/pages/admin/box_edit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/box_provider.dart';

class ViewBoxScreen extends StatelessWidget {
  final String boxId;

  const ViewBoxScreen({super.key, required this.boxId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Box Details'),
      ),
      body: FutureBuilder(
        future: Provider.of<BoxProvider>(context, listen: false).fetchBoxDetails(boxId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading box details'));
          } else {
            final boxDetails = Provider.of<BoxProvider>(context).boxDetails;
            final members = Provider.of<BoxProvider>(context).members;
            final payments = Provider.of<BoxProvider>(context).payments;
            final paymentPlans = Provider.of<BoxProvider>(context).paymentPlans;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (boxDetails['profile_image_url'] != null)
                    Center(
                      child: Image.network(
                        boxDetails['profile_image_url'],
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, size: 150),
                      ),
                    )
                  else
                    const Center(
                      child: Icon(Icons.image_not_supported, size: 150),
                    ),
                  const SizedBox(height: 10),
                  Text('Box Name: ${boxDetails['name']}', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  const Text('Members:', style: TextStyle(fontSize: 18)),
                  ...members.map((member) => ListTile(
                        title: Text(member['name']),
                        subtitle: Text(member['email']),
                      )),
                  const SizedBox(height: 10),
                  const Text('Payments:', style: TextStyle(fontSize: 18)),
                  ...payments.map((payment) => ListTile(
                        title: Text('Amount: ${payment['amount']} ${payment['currency']}'),
                        subtitle: Text('Date: ${payment['date']}'),
                      )),
                  const SizedBox(height: 10),
                  const Text('Payment Plans:', style: TextStyle(fontSize: 18)),
                  ...paymentPlans.map((plan) => ListTile(
                        title: Text(plan['name']),
                        subtitle: Text('Price: ${plan['price']} ${plan['currency']}'),
                      )),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EditBoxScreen(boxId: boxId),
                      ));
                    },
                    child: const Text('Edit Box'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
