import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class TryPlusScreen extends StatefulWidget {
  const TryPlusScreen({super.key});

  @override
  State<TryPlusScreen> createState() => _TryPlusScreenState();
}

class _TryPlusScreenState extends State<TryPlusScreen> {
  String? _selectedPlan;
  String _currentPlan = "Free Plan";

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPlan = prefs.getString("plan") ?? "Free Plan";
    });
  }

  // ---------------- PAYMENT METHODS ----------------

  void _showPaymentMethods() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _paymentOption("Visa / MasterCard", Icons.credit_card, () {
                Navigator.pop(context);
                _fakePaymentDialog("Visa");
              }),
              _paymentOption("Vodafone Cash", Icons.phone_android, () {
                Navigator.pop(context);
                _fakePaymentDialog("Vodafone Cash");
              }),
              _paymentOption("InstaPay", Icons.account_balance_wallet, () {
                Navigator.pop(context);
                _fakePaymentDialog("InstaPay");
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _paymentOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: onTap,
    );
  }

  // ---------------- FAKE PAYMENT DIALOG ----------------

  void _fakePaymentDialog(String method) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text("Pay with $method"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (method == "Visa")
                _visaCardPreview(controller)
              else
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: method == "Vodafone Cash"
                        ? "Phone Number"
                        : "Account / Email",
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _fakeLoadingPayment(method);
              },
              child: const Text("Pay"),
            ),
          ],
        );
      },
    );
  }

  // 💳 Visa Card UI
  Widget _visaCardPreview(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Colors.blueGrey],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "VISA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Card Number",
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  // ⏳ Loading fake payment
  Future<void> _fakeLoadingPayment(String method) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) Navigator.pop(context);

    _showSuccessDialog(method);
  }

  // 🎉 Success dialog
  void _showSuccessDialog(String method) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text("Payment Successful"),
          content: Text("The required amount has been withdraw using $method"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ---------------- PLAN SELECT ----------------

  void _selectPlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "Current Plan: $_currentPlan",
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _planCard("Free Plan", "Limited analysis", "0 EGP"),
            _planCard("Pro Plan", "Unlimited + faster AI", "99 EGP"),
            _planCard("Premium", "All features + priority", "199 EGP"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_selectedPlan == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Select a plan first")),
                  );
                  return;
                }

                if (_selectedPlan == "Free Plan") {
                  setState(() {
                    _currentPlan = "Free Plan";
                  });
                } else {
                  _showPaymentMethods();
                }
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PLAN CARD ----------------

  Widget _planCard(String title, String desc, String price) {
    final isSelected = _selectedPlan == title;

    return GestureDetector(
      onTap: () => _selectPlan(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
