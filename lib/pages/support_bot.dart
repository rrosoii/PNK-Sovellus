class SupportBot {
  String getReply(String message) {
    message = message.toLowerCase();

    // --- Ajanvaraus ---
    if (message.contains("ajanvaraus") ||
        message.contains("varaa aika") ||
        message.contains("aika") ||
        message.contains("varaus")) {
      return "Ajanvarauksen voit tehdä Paavo Nurmi -keskuksen varauskalenterista (https://pnk.fi/varauskalenteri) tai soittamalla asiakaspalveluun. ";
    }

    // --- Nettisivut ---
    if (message.contains("sivut") ||
        message.contains("nettisivut") ||
        message.contains("website") ||
        message.contains("linkki")) {
      return "Paavo Nurmi -keskuksen viralliset nettisivut löytyvät osoitteesta: www.pnk.fi.";
    }

    // --- Aukioloajat ---
    if (message.contains("aukiolo") ||
        message.contains("auki") ||
        message.contains("milloin") ||
        message.contains("open")) {
      return "Paavo Nurmi -keskus on avoinna arkisin klo 8–20 ja viikonloppuisin klo 10–18.";
    }

    // --- Uimahalli / sali / liikunta ---
    if (message.contains("uimahalli") ||
        message.contains("uida") ||
        message.contains("uinti")) {
      return "Uimahalli on avoinna päivittäin. Uinnin aikataulut, radat ja hinnat löytyvät nettisivuilta.";
    }

    if (message.contains("sali") ||
        message.contains("kuntosali") ||
        message.contains("gym")) {
      return "Kuntosali on käytettävissä aukioloaikojen mukaan. Kortilla pääsee omatoimisesti sisään.";
    }

    // --- Liput / hinnat ---
    if (message.contains("hinta") ||
        message.contains("liput") ||
        message.contains("maksu")) {
      return "Ajantasaiset hinnat löytyy nettisivuilta kohdasta 'Hinnasto'.";
    }

    // --- Yhteystiedot ---
    if (message.contains("yhteys") ||
        message.contains("email") ||
        message.contains("sähköposti")) {
      return "Asiakaspalvelun sähköposti: asiakaspalvelu@paavonurmikeskus.fi.";
    }

    // Default vastaus
    return "En ihan ymmärtänyt. Voitko tarkentaa? 😊";
  }
}
