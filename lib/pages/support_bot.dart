class SupportBot {
  String getReply(String message) {
    final lower = message.toLowerCase();

    // --- Ajanvaraus ---
    if (lower.contains("ajanvaraus") ||
        lower.contains("varaa aika") ||
        lower.contains("aika") ||
        lower.contains("varaus")) {
      return "Ajanvarauksen voit tehdä Paavo Nurmi -keskuksen varauskalenterissa (https://pnk.fi/varauskalenteri) tai soittamalla asiakaspalveluun.";
    }

    // --- Nettisivut ---
    if (lower.contains("sivut") ||
        lower.contains("nettisivut") ||
        lower.contains("website") ||
        lower.contains("linkki")) {
      return "Paavo Nurmi -keskuksen viralliset nettisivut löytyvät osoitteesta www.pnk.fi.";
    }

    // --- Aukioloajat ---
    if (lower.contains("aukiolo") ||
        lower.contains("auki") ||
        lower.contains("milloin") ||
        lower.contains("open")) {
      return "Paavo Nurmi -keskus on avoinna arkisin klo 8–20 ja viikonloppuisin klo 10–18.";
    }

    // --- Uimahalli / sali / liikunta ---
    if (lower.contains("uimahalli") || lower.contains("uida") || lower.contains("uinti")) {
      return "Uimahalli on avoinna päivittäin. Uinnin aikataulut, radat ja hinnat löytyvät nettisivuilta.";
    }

    if (lower.contains("sali") || lower.contains("kuntosali") || lower.contains("gym")) {
      return "Kuntosali on käytettävissä aukioloaikojen mukaan. Kulkuoikeudella pääset sisään omatoimisesti.";
    }

    // --- Liput / hinnat ---
    if (lower.contains("hinta") || lower.contains("liput") || lower.contains("maksu")) {
      return "Ajantasaiset hinnat löytyvät nettisivuilta kohdasta “Hinnasto”.";
    }

    // --- Yhteystiedot ---
    if (lower.contains("yhteys") || lower.contains("email") || lower.contains("sähköposti")) {
      return "Asiakaspalvelun sähköposti: asiakaspalvelu@paavonurmikeskus.fi.";
    }

    // Default vastaus
    return "En ihan ymmärtänyt. Voitko tarkentaa? 🙂";
  }
}
