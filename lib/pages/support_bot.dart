import 'dart:math';

class SupportBot {
  // ===== MEMORY =====
  String? lastTopic;
  String? lastSymptom;
  String? lastExercise;

  int fatigueLevel = 0;
  int stressLevel = 0;
  int hydrationLevel = 0;

  String getReply(String message) {
    final text = _normalize(message);

    // ================= EMOTIONS =================

    if (_any(text,
        ["ahdist", "stress", "uupun", "vasy", "huono olo", "voimat loppu"])) {
      lastTopic = "mood";
      stressLevel++;
      fatigueLevel++;

      return _oneOf([
        "Kuulostaa siltä että olet kuormittunut.",
        "Oletko nukkunut ja syönyt hyvin viime aikoina?",
        "Pitkittynyt stressi näkyy kehossa nopeasti.",
      ]);
    }

    if (lastTopic == "mood" &&
        _any(text, ["vasy", "huonosti", "en jaksa", "liikaa", "paine"])) {
      return "Haluatko että annan konkreettisia vinkkejä jaksamiseen?";
    }

    // ================= HYDRATION =================

    if (_any(text, ["ves", "juo", "jano", "nest"])) {
      hydrationLevel++;
      lastTopic = "water";

      return _oneOf([
        "Nestevajaus aiheuttaa väsymystä ja päänsärkyä.",
        "Muista juoda säännöllisesti, ei vain kun janottaa.",
        "Hyvä tavoite on kirkas tai vaalea virtsa.",
      ]);
    }

    // ================= SLEEP =================

    if (_any(text, ["uni", "uneton", "nukk", "vasyera"])) {
      lastTopic = "sleep";
      return _oneOf([
        "Uni on palautumisen ydin.",
        "Jos heräät väsyneenä, uni ei ehkä ole ollut laadukasta.",
        "Säännöllinen nukkumaanmeno auttaa kehoa rytmiin.",
      ]);
    }

    // ================= NUTRITION =================

    if (_any(text, ["ruoka", "syominen", "ravinto", "dieetti", "prote"])) {
      lastTopic = "food";
      return _oneOf([
        "Keho tarvitsee polttoaineen toimiakseen.",
        "Proteiini auttaa palautumisessa.",
        "Epäsäännöllinen syöminen vaikuttaa mielialaan ja jaksamiseen.",
      ]);
    }

    // ================= EXERCISE =================

    if (_any(text, [
      "liikunta",
      "treeni",
      "kunto",
      "salilla",
      "juoks",
      "urheilu",
      "lenk"
    ])) {
      lastTopic = "exercise";

      return _oneOf([
        "Liikunta on hyvä lääke melkein kaikkeen.",
        "Muistatko palautumisen treenin jälkeen?",
        "Liikaa treeniä näyttää ulospäin motivaatiolta mutta tuntuu kehossa uupumisena.",
      ]);
    }

    if (lastTopic == "exercise") {
      return _handleExerciseFollowUp(text);
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
      "jäykkä"
    ])) {
      lastTopic = "pain";
      return _oneOf([
        "Kuulostaa ikävältä. Missä kohtaa kehoa kipu tuntuu?",
        "Onko kipu jatkuvaa vai vain liikkeessä?",
        "Sattuuko se levossa vai vain liikkuessa?",
      ]);
    }

    if (lastTopic == "pain") {
      return _handlePain(text);
    }

    // ================= PAAVO NURMI CENTER =================

    if (_any(text, ["ajanvara", "varaa aika", "aika", "aja","varaa"])) {
      return "Ajanvarauksen voi tehdä nettisivuilla osoitteesta https://pnk.fi/varauskalenteri/ tai soittamalla numeroon 045 783 11203 arkisin klo 8-16!";
    }

    if (_any(text, ["auki", "aukiolo"])) {
      return "Olemme auki arkisin klo 8–16. Käynnit vain ajanvarauksella.";
    }

    if (_any(text, ["pnk", "nettisiv"])) {
      return "Viralliset sivut löytyvät osoitteesta pnk.fi.";
    }

    if (_any(text, ["yhteys", "whatsapp", "soitto"])) {
      return "Asiakaspalvelun numero on 045 783 68551 arkisin klo 8–16.";
    }

    // ================= SMALL TALK =================

    if (_any(text, ["moi", "hei", "moikka"])) {
      return _oneOf([
        "Hei! Miten voin auttaa?",
        "Moi! Kysy vapaasti esim. unesta tai liikunnasta.",
        "Terve! Miten menee?",
      ]);
    }

    if (_any(text, ["kiitos", "kiitti"])) {
      return _oneOf([
        "Ole hyvä!",
        "Ilo auttaa.",
        "Kiva kuulla.",
      ]);
    }

    // ================= QUESTION FALLBACK =================

    if (_isQuestion(text)) {
      return "Voitko tarkentaa vähän, niin voin auttaa paremmin?";
    }

    // ================= DEFAULT =================

    return _oneOf([
      "En aivan ymmärtänyt – kerro uudestaan?",
      "Voisitko muotoilla asian toisin?",
      "Tarkennathan hieman.",
    ]);
  }

  // ================= HANDLERS =================

  String _handleExerciseFollowUp(String t) {
    if (_any(t, ["liikaa", "rasitus", "ylikunto"])) {
      return "Ylikuormitus näkyy väsymyksenä, univaikeuksina ja suorituskyvyn laskuna.";
    }

    if (_any(t, ["tauko", "lepo"])) {
      return "Palautuminen ei ole laiskuutta. Se on kehitystä.";
    }

    if (_any(t, ["voima", "tai", "kestävyys"])) {
      return "Tasapaino voiman ja kestävyyden välillä ehkäisee vammoja.";
    }

    lastTopic = null;
    return "Haluatko vinkkejä palautumiseen tai treeniohjelmaan?";
  }

  String _handlePain(String t) {
    if (_any(t, ["polvi"])) {
      return "Polvikipu liittyy usein rasitukseen, juoksuun tai väärään kuormitukseen. Onko kipu pahinta portaissa tai kyykyissä?";
    }

    if (_any(t, ["nilkka"])) {
      return "Nilkkakipu voi tulla nyrjähdyksestä tai huonosta tuesta. Onko se turvonnut?";
    }

    if (_any(t, ["lonkka"])) {
      return "Lonkkakipu voi heijastua reiteen tai alaselkään. Onko kävely vaikeaa?";
    }

    if (_any(t, ["selka", "hartia"])) {
      return "Selkä- ja hartiakipu liittyy usein istumiseen tai huonoon ergonomiaan. Kuinka paljon istut päivässä?";
    }

    if (_any(t, ["paa"])) {
      return "Päänsärky liittyy usein stressiin, uneen tai nesteeseen. Oletko juonut tarpeeksi?";
    }

    return _oneOf([
      "Onko kipu terävää vai särkyvää?",
      "Kuinka kauan kipu on jatkunut?",
      "Paheneeko se liikkeessä?",
    ]);
  }

  // ================= TOOLS =================

  bool _any(String input, List<String> keys) {
    return keys.any((k) => input.contains(k));
  }

  bool _isQuestion(String text) {
    return text.contains("?") ||
        _any(text, ["miksi", "miten", "paljon", "voiko"]);
  }

  String _oneOf(List<String> replies) {
    replies.shuffle(Random());
    return replies.first;
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll("ä", "a")
        .replaceAll("ö", "o")
        .replaceAll("å", "a");
  }
}
