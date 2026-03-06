import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportBot {
  // ===== MEMORY =====
  String? lastTopic;
  String? lastSymptom;
  String? lastExercise;

  int fatigueLevel = 0;
  int stressLevel = 0;
  int hydrationLevel = 0;

  final Uri bookingUrl = Uri.parse("https://pnk.fi/varauskalenteri");

  Future<void> _openBooking() async {
    await launchUrl(bookingUrl, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(String number) async {
    final Uri phone = Uri.parse("tel:$number");
    await launchUrl(phone);
  }

  List<TextSpan> getReply(String message) {
    final text = _normalize(message);

    // ================= EMOTIONS =================

    if (_any(text,
        ["stress", "uupun", "uupum", "vasy", "huono olo", "voimat loppu"])) {
      return [
        const TextSpan(
            text:
                "Kuulostaa siltä että olet kuormittunut. Haluaisitko keskustella asiasta lääkärin kanssa? Voit varata ajan lääkärin vastaanotolle "),
        _bookingLink(),
        const TextSpan(text: " tai soittamalla numeroon "),
        _phoneLink("04578368551"),
      ];
    }

    // ================= NUTRITION =================

    if (_any(text,
        ["ruoka", "syominen", "ravinto", "dieetti", "prote", "ruokaval"])) {
      lastTopic = "food";

      return [
        const TextSpan(
            text:
                "Kiva että ravitsemus kiinnostaa! Halutessasi voit varata ajan ravitsemusterapeuttimme vastaanotolle "),
        _bookingLink(),
      ];
    }

    // ================= EXERCISE =================

    if (_any(
        text, ["liikunta", "treeni", "kunto", "salilla", "juoks", "urheilu"])) {
      return [
        const TextSpan(
            text:
                "Hienoa, että liikunta kiinnostaa! Tiesitkö, että jos haluat tietää enemmän omasta kunnostasi, voit varata ajan kuntotesteihin "),
        _bookingLink(),
        const TextSpan(text: "."),
      ];
    }

    if (_any(text, ["liikuntal", "urheilul"])) {
      return [
        const TextSpan(
            text:
                "Meillä PNK:ssa lääkärin vastaanottoa pitävät liikuntalääketieteeseen erikoistuvat lääkärit. Voit varata ajan lääkärille "),
        _bookingLink(),
        const TextSpan(text: " tai soittamalla numeroon "),
        _phoneLink("04578368551"),
        const TextSpan(text: "."),
      ];
    }

    // ================= PAIN =================

    if (_any(text, [
      "kipu",
      "kipe",
      "sarky",
      "sattuu",
      "kolottaa",
      "vamma",
      "turvonnut",
      "aristaa",
      "jaykka"
    ])) {
      lastTopic = "pain";

      return [
        const TextSpan(
            text:
                "Kuulostaa ikävältä. Tiesitkö, että voit varata meiltä ajan lääkärin vastaanotolle "),
        _bookingLink(),
        const TextSpan(text: "."),
      ];
    }

    // ================= APPOINTMENTS =================

    if (_any(text, ["ajanvara", "varaa aika", "aika", "varaa"])) {
      return [
        const TextSpan(text: "Ajanvarauksen voit tehdä kätevästi sähköisen "),
        _bookingLink(),
        const TextSpan(
            text:
                ". Jos asiasi koskee suorituskyvyn mittauksia, voit soittaa numeroon "),
        _phoneLink("04578311203"),
        const TextSpan(
            text:
                ". Jos asiasi koskee lääkärin vastaanottoa tai laboratoriokäyntiä, soita numeroon "),
        _phoneLink("04578368551"),
        const TextSpan(text: ". Toimistomme ovat avoinna arkisin klo 8–16."),
      ];
    }

    // ================= OPENING HOURS =================

    if (_any(text, ["auki", "aukiolo"])) {
      return [
        const TextSpan(
            text: "Olemme auki arkisin klo 8–16. Käynnit vain ajanvarauksella.")
      ];
    }

    // ================= WEBSITE =================

    if (_any(text, ["pnk", "nettisiv"])) {
      return [
        const TextSpan(text: "Viralliset sivut löytyvät osoitteesta "),
        TextSpan(
          text: "https://pnk.fi/",
          style: const TextStyle(
              color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launchUrl(Uri.parse("https://pnk.fi/"));
            },
        ),
      ];
    }

    // ================= SMALL TALK =================

    if (_any(text, ["moi", "hei", "moikka"])) {
      return [const TextSpan(text: "Hei! Miten voin auttaa?")];
    }

    if (_any(text, ["kiitos", "kiitti"])) {
      return [const TextSpan(text: "Ole hyvä!")];
    }

    if (_any(text, ["ihminen", "henkilo"])) {
      return [
        const TextSpan(
            text:
                "Valitettavasti olen chättibotti. Asiakaspalvelun tavoitat arkisin klo 8-16 soittamalla numeroon "),
        _phoneLink("04578368551"),
        const TextSpan(text: "."),
      ];
    }

    // ================= DEFAULT =================

    return [const TextSpan(text: "En aivan ymmärtänyt – kerro uudestaan?")];
  }

  // ================= LINK BUILDERS =================

  TextSpan _bookingLink() {
    return TextSpan(
      text: "varauskalenterista",
      style: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(bookingUrl, mode: LaunchMode.externalApplication);
        },
    );
  }

  TextSpan _phoneLink(String number) {
    return TextSpan(
      text: number,
      style: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Uri.parse("tel:$number"));
        },
    );
  }

  // ================= TOOLS =================

  bool _any(String input, List<String> keys) {
    return keys.any((k) => input.contains(k));
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll("ä", "a")
        .replaceAll("ö", "o")
        .replaceAll("å", "a");
  }
}
