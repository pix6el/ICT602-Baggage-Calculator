import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const BaggageCalculatorApp());
}

// -----------------------------------------------------------------------------
// MAIN APP - This is the root of the application
// -----------------------------------------------------------------------------
class BaggageCalculatorApp extends StatelessWidget {
  const BaggageCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baggage Fee Estimator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // We set the initial screen to the HomePage
      home: const HomePage(),
    );
  }
}

// -----------------------------------------------------------------------------
// HOME PAGE - Contains the form to calculate the excess baggage fee
// -----------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers to get the text input from the user (weight and rate)
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  // Variable to store the selected ticket class. The default is 'Economy'.
  String _ticketClass = 'Economy';

  // Variables to store the calculation results so they can be displayed
  double _excessWeight = 0.0;
  double _excessCharge = 0.0;
  double _totalAmount = 0.0;

  // This function performs the calculation when the 'Calculate' button is pressed
  // I added comments for each calculation step as required by the assignment
  void _calculateFee() {
    // 1. Get the weight and rate from the text fields. 
    // tryParse safely converts the text to a number, defaulting to 0.0 if empty/invalid.
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double rate = double.tryParse(_rateController.text) ?? 0.0;

    // 2. Determine the allowed weight (X kg) based on the chosen ticket class
    // economy = 20 kg, business = 40 kg
    double allowedWeight = (_ticketClass == 'Economy') ? 20.0 : 40.0;

    // 3. Calculate excess weight (weight in kg - X kg)
    double calculatedExcessWeight = weight - allowedWeight;
    
    // If the baggage is less than or equal to the allowed weight, the excess is 0 kg (never negative)
    if (calculatedExcessWeight < 0) {
      calculatedExcessWeight = 0.0;
    }

    // 4. Calculate the excess baggage charge (excess weight in kg * rate per kg)
    double calculatedExcessCharge = calculatedExcessWeight * rate;

    // 5. Calculate total amount payable (excess baggage charge + 8% service tax)
    // We multiply the charge by 0.08 to get the 8% tax, then add it to the base charge
    double calculatedTotal = calculatedExcessCharge + (0.08 * calculatedExcessCharge);

    // 6. Update the state to refresh the UI with the newly calculated values
    setState(() {
      _excessWeight = calculatedExcessWeight;
      _excessCharge = calculatedExcessCharge;
      _totalAmount = calculatedTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baggage Fee Estimator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // We add a Drawer for the Navigation Menu (Home and About)
      drawer: const NavigationMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // SingleChildScrollView allows the screen to scroll if the keyboard pops up
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Baggage Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Input Field: Baggage Weight
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Baggage weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Input Field: Ticket Class Dropdown (Economy or Business)
              DropdownButtonFormField<String>(
                initialValue: _ticketClass,
                decoration: const InputDecoration(
                  labelText: 'Ticket Class',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Economy', child: Text('Economy (20 kg allowance)')),
                  DropdownMenuItem(value: 'Business', child: Text('Business (40 kg allowance)')),
                ],
                onChanged: (String? newValue) {
                  // Update the selected ticket class when changed
                  setState(() {
                    _ticketClass = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Input Field: Excess Baggage Rate
              TextField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Excess baggage rate per kg (RM)',
                  hintText: 'e.g., 15 for Economy, 12 for Business',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Action: Calculate Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _calculateFee,
                  child: const Text('Calculate', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),

              // Output: Results Section
              const Text(
                'Results:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Output: Excess Baggage Weight
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Excess Baggage Weight:'),
                          Text('${_excessWeight.toStringAsFixed(2)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Output: Excess Baggage Charge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Excess Baggage Charge:'),
                          Text('RM ${_excessCharge.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 32),
                      
                      // Output: Total Amount Payable
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount Payable\n(incl. 8% tax):', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('RM ${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ABOUT PAGE - Displays application icon, author info, and github link
// -----------------------------------------------------------------------------
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Function to open the GitHub URL using the url_launcher package
  Future<void> _launchURL() async {
    // Note: Change this to your actual GitHub repository URL before submission!
    final Uri url = Uri.parse('https://github.com/your-username/your-repo');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Include the same NavigationMenu Drawer so we can navigate back to Home
      drawer: const NavigationMenu(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Application Icon (Using custom app logo)
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 24),
              
              // 2. Author Information
              // NOTE: Update these details with your actual Name and Matric Number
              const Text('YOUR NAME HERE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Matric No: 202XXXXXXX', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Course: ICT602 (Mobile Technology)', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),

              // 3. Clickable GitHub URL
              InkWell(
                onTap: _launchURL,
                child: const Text(
                  'Open GitHub Repository',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 4. Copyright Notice
              const Text(
                '© 2024 Universiti Teknologi MARA. All rights reserved.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NAVIGATION MENU - A Drawer widget used in both Home and About pages
// -----------------------------------------------------------------------------
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with a blue background
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'App Navigation',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          
          // Navigation Link to Home Page
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Close the drawer and replace the current screen with Home
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          
          // Navigation Link to About Page
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Close the drawer and replace the current screen with About
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
