import 'package:flutter/material.dart';

class OnboardingScreenOne extends StatelessWidget {
      static const String pageName = '/OnboardingScreenOne';

  const OnboardingScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4EBD1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 50),
          Image.asset('assets/images/superhero.png'),
          const Text(
            'بس خلاص كدة... يلا نبدأ الشغل بقى',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Column(
            children: [
              const Text(
                'لو انت انجلشـاوي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                'لو معاك باسورد من الابلكيشن دة.. ادخل بيه على طول',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('انجلشـاوي .. دخلني يلا'),
              ),
              const SizedBox(height: 30),
              const Text(
                'لو عايز تبقى انجلشـاوي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                'سجل اكونت جديد وابدأ معانا مكثف السوبرهيروز...',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('عايز اعمل اكونت'),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class OnboardingScreenTwo extends StatelessWidget {
  const OnboardingScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B4C96),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 50),
          const Text(
            'متابعة المكثف',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'مش هنسيبك تقصر\nفريق انجلشـاوي معاك في كل مكان..\nهنتابع مستواك ونركز على النقط اللي انت محتاج تضبطها',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.yellowAccent),
            ),
          ),
          Image.asset('assets/images/hiking.png'),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('ها .. وايه تاني!'),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'انجز.. دخلني على طول...',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

class OnboardingScreenThree extends StatelessWidget {
  const OnboardingScreenThree({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final guardianController = TextEditingController();
    final yearController = TextEditingController();
    final cityController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF4B4C96),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'هيرو جديد!\nعايز اشترك مع انجلشـاوي',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'الاسم رباعي للهيرو بتاعنا...'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(hintText: 'رقم الموبايل...'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: guardianController,
              decoration: const InputDecoration(hintText: 'رقم موبايل ولي الامر...'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(hintText: 'سنة كام!'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(hintText: 'ساكن فين!'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // submit logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('ابدأ دلوقتي...'),
            ),
          ],
        ),
      ),
    );
  }
}
