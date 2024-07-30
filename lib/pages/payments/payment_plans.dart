import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_plan_provider.dart';
import '../../auth/auth_provider.dart';
import 'payment.dart';

class PaymentPlansPage extends StatefulWidget {
  const PaymentPlansPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaymentPlansPageState createState() => _PaymentPlansPageState();
}

class _PaymentPlansPageState extends State<PaymentPlansPage> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentPlanProvider = Provider.of<PaymentPlanProvider>(context, listen: false);
    paymentPlanProvider.fetchPaymentPlans(authProvider.token!);
  }

  @override
  Widget build(BuildContext context) {
    final paymentPlanProvider = Provider.of<PaymentPlanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Plans'),
      ),
      body: paymentPlanProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: paymentPlanProvider.paymentPlans.length,
              itemBuilder: (ctx, index) {
                final plan = paymentPlanProvider.paymentPlans[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(plan['plan_id']),
                    subtitle: Text(
                      '${plan['amount']} ${plan['currency']}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PaymentDetailsPage(plan: plan),
                      ));
                    },
                  ),
                );
              },
            ),
    );
  }
}
