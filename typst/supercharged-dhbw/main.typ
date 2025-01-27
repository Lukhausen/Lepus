#import "@preview/supercharged-dhbw:3.4.0": *
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary

#show: supercharged-dhbw.with(
  title: "Exploring the Impact of Synthetic Chain-of-Thought Fine-Tuning on LLM Reasoning Abilities",
  authors: (
    (name: "Lukas Marschhausen", student-id: "1840227", course: "TINF22AI1", course-of-studies: "Applied Computer Science", company: (
      (name: "Cisco Systems GmbH", post-code: "65760", city: "Eschborn")
    )),
    (name: "Marc Schmengler", student-id: "1234567", course: "TINF22AI1", course-of-studies: "Applied Computer Science", company: (
      (name: "XYZ GmbH", post-code: "12345", city: "Berlin")
    )),

  ),
  acronyms: acronyms, // displays the acronyms defined in the acronyms dictionary
  at-university: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary, // displays the glossary terms defined in the glossary dictionary
  language: "en", // en, de
  supervisor: (company: "-"),
  university: "Cooperative State University Baden-Württemberg",
  university-location: "Mannheim",
  university-short: "DHBW",
  // for more options check the package documentation (https://typst.app/universe/package/supercharged-dhbw)
)


// Edit this content to your liking

= Trainingsprozess und Inferenz (Train-Time vs. Test-Time)

Im Rahmen moderner KI-Anwendungen lassen sich zwei zentrale Phasen unterscheiden: Zum einen der Trainingsprozess, zum anderen die Inferenz. Während des Trainings, oft als „Train-Time Compute“ bezeichnet, wird ein Modell mithilfe großer Datenmengen und spezieller Optimierungsverfahren angepasst. Hierfür sind umfangreiche Rechenressourcen erforderlich, da jedes Eingabebeispiel den Algorithmus zunächst in einem Vorwärtsdurchlauf durchläuft, bevor der sogenannte Backpropagation-Schritt erfolgt. Dieser Prozess dient dazu, die Parameter so zu verändern, dass das Modell immer zuverlässigere Vorhersagen treffen kann. Je nach Komplexität und Größe des Netzwerks kann das Training sehr viel Zeit in Anspruch nehmen und geht üblicherweise mit hohen Kosten für Hardware und Energie einher.

Sobald das Modell ausreichend gut angepasst ist, wird es in den Einsatz überführt. Diese praktische Anwendung bezeichnet man als Inferenz oder „Test-Time Compute“. Hier geht es ausschließlich darum, die gelernten Parameter abzurufen und auf neue Eingaben anzuwenden. Anders als beim Training wird das Modell während der Inferenz nicht mehr verändert, sondern nutzt die zuvor gelernten Zusammenhänge, um Vorhersagen oder Entscheidungen zu treffen. Dieser Vorwärtsdurchlauf ist zwar in der Regel deutlich schneller und weniger rechenintensiv als das Training, er kann jedoch je nach Modellgröße, Einsatzumgebung und Anzahl der Anfragen trotzdem relevante Ressourcen beanspruchen. In produktiven Szenarien ist daher eine effiziente Inferenz ebenso wichtig wie ein gut organisierter Trainingsprozess, weil das eingesetzte KI-System oftmals große Mengen an Anfragen in kurzer Zeit bewältigen muss.

= Verschiedene Modellarchitekturen und ihr Rechenaufwand

In der Welt der KI existieren diverse Modellarchitekturen, die jeweils ihren eigenen Rechenaufwand mit sich bringen und damit sowohl das Training als auch die Inferenz unterschiedlich beeinflussen. Transformers wie GPT, BERT oder T5 haben sich in letzter Zeit insbesondere in der Sprachverarbeitung etabliert. Ihre Selbstaufmerksamkeitsmechanismen ermöglichen es, kontextbezogene Informationen über lange Sequenzen hinweg effizient zu erfassen, was allerdings im Training große Ressourcen erfordert. Sobald sie jedoch einmal daraufhin optimiert wurden, umfangreiche Texte und komplexe Zusammenhänge zu verstehen, arbeiten sie in der Inferenz meist trotz ihrer hohen Parametermengen relativ stabil, sofern geeignete Hardware (zum Beispiel GPUs) verfügbar ist.

RNNs und LSTMs waren früher die dominierenden Architekturen im Bereich natürlicher Sprachverarbeitung, ehe die Transformer-Modelle aufkamen. Sie verarbeiten Daten seriell, was oft zu längeren Trainingszeiten führt, wenn es um sehr lange Sequenzen geht. Durch das schrittweise Voranschreiten in jedem Zeitschritt entsteht während des Trainings ein größerer Aufwand, der sich in einer häufig vergleichsweise langsameren Konvergenz äußert. Für die Anwendung selbst benötigt ein ausgereiftes RNN oder LSTM im Allgemeinen weniger Leistung als Transformers, ist aber bei sehr komplexen Aufgaben oft nicht so leistungsstark.

Im Bildbereich kommen vor allem Convolutional Neural Networks zum Einsatz. Diese Netzwerke nutzen Faltungsoperationen, um Informationen aus lokal begrenzten Bildbereichen zu extrahieren. Aufgrund ihrer Gewichtsteilung und ihrer hierarchischen Struktur sind sie in vielen Bildklassifikations- und Segmentierungsaufgaben deutlich effizienter als generische vollverbundene Architekturen. Je tiefer ein CNN jedoch wird, desto mehr Ressourcen verschlingt sowohl das Anpassen der Parameter als auch das Ausführen von Vorhersagen. Bei vielen praktischen Einsätzen übersteigt das Aufkommen an Inferenzanfragen jedoch den einmaligen Trainingsaufwand deutlich, weshalb man häufig versucht, die Netzwerkstruktur so zu wählen, dass der regelmäßige Betrieb nicht zu kostspielig wird. Insgesamt bestimmt also die Art der gewählten Architektur maßgeblich, wie hoch der Rechenaufwand während der Entwicklungsphase ausfällt und in welchem Ausmaß das fertige Modell im Einsatz skaliert werden kann.

= Chain of Thought

Das Chain-of-Thought-Prinzip beschreibt eine Strategie, bei der KI-Modelle ihre Gedankengänge in mehreren, nachvollziehbaren Zwischenschritten ausformulieren, anstatt direkt nur das Endergebnis zu präsentieren. Dies geschieht häufig in größeren Sprachmodellen, um komplexe Fragestellungen wie mathematische Aufgaben, logische Schlussfolgerungen oder das Verständnis langer Texte zu bewältigen. Ein einfaches Beispiel wäre eine Rechenaufgabe, bei der das Modell nicht nur die Summe zweier Zahlen nennt, sondern Schritt für Schritt erläutert, wie es zu dieser kommt: Erst werden die Zahlen in ihre Stellenwerte zerlegt und einzeln addiert, bis schließlich das korrekte Resultat vorliegt. Dank dieser schrittweisen Strukturierung und Darstellung des Lösungswegs bleiben Irrtümer leichter erkennbar und können gegebenenfalls korrigiert werden. In der Praxis findet das Verfahren vor allem dort Anwendung, wo eine klare Herleitung entscheidend ist, beispielsweise bei kniffligen Rätselaufgaben, im Bereich der automatisierten Textanalyse oder bei der Analyse juristischer Dokumente. Diese explizite Offenlegung des Denkprozesses erhöht nicht nur die Genauigkeit, sondern fördert auch das Vertrauen in die Antworten von KI-Systemen, da Anwenderinnen und Anwender die Ausführungen besser nachvollziehen können.

= Scaling Laws

Unter dem Begriff „Scaling Laws“ versteht man Richtlinien oder Beobachtungen, die beschreiben, wie sich die Leistung von KI-Modellen in Abhängigkeit von ihrer Größe, der verfügbaren Datenmenge und der aufgewendeten Rechenleistung entwickelt. Je größer ein neuronales Netzwerk und je umfangreicher die Trainingsdaten ausfallen, desto stärker kann im Regelfall die Genauigkeit steigen – allerdings treten oft ab einem gewissen Punkt abnehmende Grenzerträge auf. Das heißt, während die Genauigkeit zu Beginn durch zusätzliches Wachstum des Modells oder mehr Datensamples rasch verbessert wird, nimmt der Zugewinn bei gleichermaßen wachsendem Aufwand später oft nur noch langsam zu. Durch die Analyse solcher Skalierungseffekte lassen sich Vorhersagen treffen, wie viele Ressourcen nötig sind, um ein bestimmtes Leistungsniveau zu erreichen, was für die Planung groß angelegter Trainingsprojekte von erheblicher Bedeutung ist. Gleichzeitig helfen Scaling Laws dabei einzuschätzen, an welcher Stelle Optimierungen im Modelldesign oder bei den Daten am effektivsten sind.

= Hyperparameter Tuning

Hyperparameter Tuning bezeichnet das systematische Anpassen bestimmter Einstellungen im Deep-Learning-Modell, um bestmögliche Ergebnisse zu erzielen. Eine zentrale Rolle spielt dabei die Lernrate: Sie regelt, wie schnell sich die Gewichte während des Trainings verändern. Ist sie zu hoch, kann das Modell instabil werden oder gar nicht konvergieren; ist sie zu niedrig, dauert es sehr lange, bis sich ein optimaler Punkt einstellt. Auch die Batch-Größe muss sorgfältig gewählt werden: Große Batches beschleunigen zwar Berechnungen auf moderner Hardware, können jedoch dazu führen, dass sich das Modell in flachen Tälern des Fehlerraums „verfängt“ und nicht optimal konvergiert. Kleine Batches hingegen erhöhen die Varianz bei der Gradientenberechnung, sorgen aber häufig für eine robustere, wenn auch langsamere Anpassung. Darüber hinaus beeinflusst die Anzahl der Layer, wie tief das Modell seine Eingaben verarbeitet, wobei mehr Schichten oft eine höhere Rechenlast, aber auch ein stärkeres Abstraktionsvermögen bedeuten. Schließlich spielt das Dropout eine wichtige Rolle in der Regularisierung: Es legt fest, wie viele Neuronen während des Trainings temporär „ausgeschaltet“ werden, was Overfitting verringern und die Generalisierung verbessern soll. All diese Komponenten zusammen bestimmen maßgeblich, wie gut und wie schnell ein neuronales Netzwerk lernt.

= Test Time Compute

Unter dem Begriff „Test Time Compute“ versteht man den Ressourcen- und Rechenaufwand, der anfällt, wenn ein KI-Modell im praktischen Einsatz Vorhersagen trifft. Dabei muss das trainierte Netzwerk nur noch den Vorwärtsdurchlauf durchlaufen, bei dem alle Parameter bereits feststehen und nicht mehr aktualisiert werden. Während dieser Phase spielt häufig die Latenz eine entscheidende Rolle, da Modelle in Echtzeitanwendungen schnell reagieren müssen. Eine wichtige Herausforderung liegt zudem in der Skalierung, wenn viele Anfragen in kurzer Zeit bearbeitet werden sollen. Um die dafür nötige Leistung zu reduzieren und die Geschwindigkeit zu erhöhen, kommen häufig Techniken wie Komprimierung, Quantisierung oder Model Distillation zum Einsatz. Auf diese Weise lässt sich ein effizienter und kostengünstiger Betrieb des trainierten Systems gewährleisten.

----- welches ist besser?

Test-Time Compute bezieht sich auf den Rechenaufwand, der erforderlich ist, um ein trainiertes Modell auf neue Eingabedaten anzuwenden, um Vorhersagen oder Klassifikationen zu machen. Diese Phase ist entscheidend für die Effizienz eines KI-Systems, da sie die tatsächliche Nutzung des Modells darstellt. Im Gegensatz zum Trainingsprozess, bei dem das Modell ständig mit neuen Daten angepasst wird, bleibt der Test-Time-Prozess unverändert, da die Modellparameter bereits optimiert sind. Der Rechenaufwand während der Inferenz hängt dabei maßgeblich von der Größe des Modells, der Hardware, auf der es läuft, und der Komplexität der Eingabedaten ab. Gerade bei großflächigen Modellen, die beispielsweise millionenfach abgefragte Daten verarbeiten, müssen spezielle Maßnahmen wie effiziente Speichertechniken oder spezialisierte Hardware, etwa GPUs oder TPUs, zum Einsatz kommen, um die Inferenz in akzeptabler Zeit durchzuführen. Zudem können Methoden wie Modellquantisierung oder Pruning helfen, den Rechenaufwand zu minimieren, ohne die Genauigkeit des Modells signifikant zu beeinträchtigen.

= Train Time Compute

„Train Time Compute“ bezeichnet den Rechenaufwand, der während des Lernprozesses eines KI-Modells entsteht. In dieser Phase werden die Gewichte des Netzwerks fortlaufend angepasst, indem das System sowohl den Vorwärtsdurchlauf als auch die Rückwärtspropagation ausführt, um geeignete Veränderungen an den Parametern vorzunehmen. Dabei spielen Faktoren wie die Größe des Datensatzes, die Wahl der Architektur und die Anzahl der Epochen eine große Rolle. Da große Modelle oft viele Schichten und dementsprechend komplexe Berechnungen besitzen, steigt der Energie- und Zeitbedarf entsprechend an. Um die Trainingszeit im Rahmen zu halten, setzen viele Projekte auf spezialisierte Hardware wie GPUs oder TPUs. Hat das Modell anschließend ein zufriedenstellendes Niveau erreicht, ist das Training abgeschlossen und die eigentlichen Anwendungen können starten.

----- welches ist besser?

Train Time Compute bezieht sich auf den Rechenaufwand, der erforderlich ist, um ein KI-Modell während des Trainingsprozesses anzupassen und zu optimieren. Das Training beinhaltet eine Reihe von Berechnungen, bei denen das Modell aus den Trainingsdaten lernt, um die bestmöglichen Gewichtungen und Parameter zu finden. In dieser Phase werden enorm viele Iterationen durchgeführt, bei denen das Modell kontinuierlich seine Fehler minimiert, sei es durch Gradientenabstieg oder andere Optimierungstechniken. Der Rechenaufwand in dieser Phase variiert je nach Modellkomplexität, Datenmenge und den eingesetzten Algorithmen. Höhere Anzahl an Parametern oder tiefere Netzwerke, wie sie beispielsweise bei Transformers oder großen neuronalen Architekturen vorzufinden sind, erhöhen den Train Time Compute erheblich. Dies führt zu längeren Trainingszeiten und einem höheren Bedarf an leistungsfähiger Hardware, sei es eine leistungsstarke GPU oder spezialisierte Maschinen in einer verteilten Umgebung.

= Test Time Compute VS Train Time Compute

Im Entwicklungsprozess moderner KI-Systeme begegnen uns zwei zentrale Phasen, die in ihrem Ressourcenbedarf und ihrer Bedeutung deutlich variieren: das Training („Train Time Compute“) und die Inferenz („Test Time Compute“). In der ersten Phase werden Modelle wie Transformers, RNNs oder CNNs mit umfangreichen Daten konfrontiert, um deren Parameter mittels Vorwärts- und Rückwärtsdurchläufen zu optimieren. Bei Architekturen wie GPT, BERT oder T5 ist dieser Prozess besonders aufwendig, da ihre Selbstaufmerksamkeitsmechanismen tief greifende Kontextinformationen erfassen und entsprechend hohe Rechenkapazitäten beanspruchen. Vergleichsweise einfacher gestaltet sich das Training bei RNNs oder LSTMs, wobei es hier aufgrund serieller Verarbeitungsschritte häufig länger dauert, eine hinreichende Genauigkeit zu erreichen. Convolutional Neural Networks hingegen bestechen durch ihre spezialisierten Faltungsoperationen für Bildverarbeitung, können aber durch zunehmende Tiefe schnell hohe Rechenleistung erfordern.

Neben der reinen Architektur wirken sich auch Größenordnungen, Datenmengen und deren Zusammenspiel auf den Trainingsaufwand aus, was in den sogenannten Scaling Laws deutlich wird. Je weiter ein Netzwerk skaliert, desto größer ist anfangs der Zuwachs an Leistung – bis irgendwann abnehmende Grenzerträge einsetzen. Um das beste Kosten-Nutzen-Verhältnis zu finden, empfiehlt sich ein zielgerichtetes Hyperparameter Tuning, bei dem etwa Lernrate und Batch-Größe präzise justiert werden, um sowohl Stabilität als auch Geschwindigkeit zu wahren. Eine zu hohe Lernrate oder übermäßige Batch-Größe kann die Konvergenz erschweren, während zu geringe Werte die Trainingszeit verlängern.

Sobald das Modell ausreichende Genauigkeit erreicht hat, rückt die Inferenz in den Vordergrund. Während dieses „Test Time Compute“ wird nur noch der Vorwärtsdurchlauf ausgeführt, ohne dass sich die Parameter weiter verändern. Hier zeigt sich die Stärke schlanker und effizienter Modellvarianten, da sie bei hohen Anfragenzahlen – insbesondere in Echtzeitanwendungen – geringeren Aufwand verursachen. Modelle mit Chain-of-Thought-Funktionalität, bei denen Zwischenschritte für komplexe Aufgaben offengelegt werden, profitieren im Einsatz von der Transparenz des Lösungswegs. Zwar erfordert der Aufbau solcher Mechanismen zunächst mehr Rechenaufwand im Training, zahlt sich jedoch aus, wenn Benutzerinnen und Benutzer die Begründungen und Teilschritte besser nachvollziehen können.

In vielen realen Umgebungen übersteigt die Häufigkeit von Inferenzanfragen den einmaligen Trainingsprozess jedoch bei Weitem. Deshalb lohnt es sich, auf eine Architektur und eine Parametrierung hinzuarbeiten, die den Ressourcenbedarf im laufenden Betrieb möglichst gering hält. Folglich ist ein überzeugendes „Test Time Compute“ in der Praxis meist vorteilhafter, da es langfristig Kosten reduziert, skalierbar bleibt und eine verlässliche Reaktionszeit garantiert.

= Examples

#lorem(30)

== Acronyms

Use the `acr` function to insert acronyms, which looks like this #acr("HTTP").

#acrlpl("API") are used to define the interaction between different software systems.

#acrs("REST") is an architectural style for networked applications.

== Glossary

Use the `gls` function to insert glossary terms, which looks like this:

A #gls("Vulnerability") is a weakness in a system that can be exploited.

== Lists

Create bullet lists or numbered lists.

- This
- is a
- bullet list

+ It also
+ works with
+ numbered lists!

== Figures and Tables

Create figures or tables like this:

=== Figures

#figure(caption: "Image Example", image(width: 4cm, "assets/ts.svg"))

=== Tables

#figure(
  caption: "Table Example",
  table(
    columns: (1fr, 50%, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [],
      [*Area*],
      [*Parameters*],
    ),

    text("cylinder.svg"),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    text("tetrahedron.svg"), $ sqrt(2) / 12 a^3 $, [$a$: edge length],
  ),
)<table>

== Code Snippets

Insert code snippets like this:

#figure(
  caption: "Codeblock Example",
  sourcecode[```ts
    const ReactComponent = () => {
      return (
        <div>
          <h1>Hello World</h1>
        </div>
      );
    };

    export default ReactComponent;
    ```],
)

#pagebreak()

== References

Cite like this #cite(form: "prose", <iso18004>).
Or like this @iso18004.

You can also reference by adding `<ref>` with the desired name after figures or headings.

For example this @table references the table on the previous page.

= Conclusion

#lorem(100)

#lorem(120)

#lorem(80)