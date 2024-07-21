// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? paymentIntentData;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey =
        "pk_test_51PJfrASBrmLFXTbxYeEcHXnxY5ZgEWHFCEqRTgWllq8UOvv3EY2rLSyX2DbJKgpoPB8AdfUMVSD6aB9x73j2gdPh00uf4UKlxe";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 195, 234, 191),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Payment",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(
            top: 350,
            left: 80,
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  await makePayment();
                },
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      "Pay",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent('20', 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Satyam Kumar',
          googlePay: const PaymentSheetGooglePay(
              // Currency and country code is accourding to India
              testEnv: true,
              currencyCode: "INR",
              merchantCountryCode: "IN"),
          // Merchant Name

          // return URl if you want to add
          // returnURL: 'flutterstripe://redirect',
        ),
      );

      displayPaymentShee();
    } catch (e) {
      print('exception on payment' + e.toString());
    }
  }

  displayPaymentShee() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        setState(() {
          paymentIntentData = null;
        });
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Paid Sucessfully')));
    } on StripeException catch (e) {
      print(e.toString());

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Cancelled"),
              ));
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization':
              'Bearer sk_test_51PJfrASBrmLFXTbxZxTugIzSEdllSmli7rsDuz8AwyfTrvaJuny2fwZ20Z2e3fRaiOG2fhg3ytkotF5IhSfdUXYK00fviJWFsA',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );
      return jsonDecode(response.body.toString());
    } catch (e) {
      print('exception' + e.toString());
    }
  }

  calculateAmount(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }
}
