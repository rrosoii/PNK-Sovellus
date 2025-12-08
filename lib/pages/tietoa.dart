import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E5AAC),
        ),
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }

  Widget _infoCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2E5AAC), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(content,
                    style: const TextStyle(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      body: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF224D9C), Color(0xFF0D3B76)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.info_outline,
                        color: Colors.white, size: 26),
                    const SizedBox(width: 8),
                    const Text(
                      "Tietoa meista",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF5A8FF7), Color(0xFF2E5AAC)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Paavo Nurmi -keskus",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Liikuntalaketieteen asiantuntijakeskus Turun yliopiston yhteydessa",
                              style:
                                  TextStyle(color: Colors.white70, height: 1.3),
                            )
                          ],
                        ),
                      ),
                      _sectionTitle("Keita olemme"),
                      _bodyText(
                        "Paavo Nurmi -keskus on Turun yliopiston yhteydessa toimiva liikuntalaketieteen keskus. "
                        "Asiantuntijayksikkomme tutkii, kouluttaa ja jakaa tietoa liikuntaan, terveyteen ja hyvinvointiin liittyen.\n\n"
                        "Toimintamme tarkein tavoite on terveyden edistaminen seka elintapasairauksien ehkäisy liikunnan ja terveiden elintapojen avulla. "
                        "Olemme aidosti yksilon ja yhteisojen terveyden asialla, jo vuodesta 1957.",
                      ),
                      _sectionTitle("Tutkimuksemme"),
                      _bodyText(
                        "Toimintamme perustana on laadukas tieteellinen tutkimus.\n\n"
                        "Yksi Paavo Nurmi -keskuksen tarkeimmista tehtavista on korkealaatuisen liikuntalaketieteellisen "
                        "tutkimuksen tuottaminen ja sen soveltaminen kaytantoon.",
                      ),
                      _sectionTitle("Arvomme"),
                      _infoCard(
                        "Terveyden edistaminen",
                        "Tyomme tavoitteena on hyvinvoinnin ja terveyden parantaminen.",
                        Icons.favorite,
                      ),
                      _infoCard(
                        "Tutkimukseen perustuva toiminta",
                        "Kaikki toimintamme nojaa tieteeseen ja tutkittuun tietoon.",
                        Icons.science,
                      ),
                      _infoCard(
                        "Yhteiskunnallinen hyoty",
                        "Tarjoamme palveluja mahdollisimman monelle.",
                        Icons.groups,
                      ),
                      _sectionTitle("Voittoa tavoittelematon toiminta"),
                      _bodyText(
                        "Paavo Nurmi -keskus on voittoa tavoittelematon organisaatio. "
                        "Kayttamalla palveluitamme tuet terveytta edistavaa tutkimusta ja autat meita "
                        "tarjoamaan terveyden ja hyvinvoinnin palveluja mahdollisimman monelle.",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
