# Application of artificial intelligence methods for arrhythmia detection based on PPG signal

Praca magisterska poświęcona wykrywaniu arytmii serca (migotania przedsionków, bradykardii, tachykardii) na podstawie sygnału fotopletyzmograficznego (PPG) przy użyciu klasycznych metod uczenia maszynowego oraz sieci neuronowych.

## Built with

![Python](https://img.shields.io/badge/Python-FFD43B?style=for-the-badge&logo=python&logoColor=blue)
![TensorFlow](https://img.shields.io/badge/TensorFlow-FF6F00?style=for-the-badge&logo=TensorFlow&logoColor=white)
![scikit-learn](https://img.shields.io/badge/scikit--learn-F7931E?style=for-the-badge&logo=scikitlearn&logoColor=white)
![Optuna](https://img.shields.io/badge/Optuna-2C4A9C?style=for-the-badge)
![MATLAB](https://img.shields.io/badge/MATLAB-0076A8?style=for-the-badge&logo=mathworks&logoColor=white)
![pandas](https://img.shields.io/badge/Pandas-2C2D72?style=for-the-badge&logo=pandas&logoColor=white)
![NumPy](https://img.shields.io/badge/Numpy-777BB4?style=for-the-badge&logo=numpy&logoColor=white)

## O projekcie

Arytmie serca (w szczególności migotanie przedsionków) są istotnym problemem zdrowotnym, a ich wczesne wykrycie ma kluczowe znaczenie dla wdrożenia leczenia. Praca koncentruje się na opracowaniu i porównaniu binarnych klasyfikatorów (zdrowy / arytmia) działających na sygnale PPG — sygnale znacznie łatwiej dostępnym niż EKG, możliwym do pozyskania np. ze smartwatchy.

W ramach pracy:

- przeanalizowano i połączono kilka publicznie dostępnych zbiorów danych PPG/EKG z adnotacjami arytmii,
- zbudowano wieloetapowy potok przetwarzania wstępnego sygnału,
- wyekstrahowano wektor cech opisujących sygnał z czterech różnych dziedzin,
- wytrenowano i porównano klasyczne modele ML oraz kilka architektur sieci neuronowych, zarówno na wektorach cech, jak i bezpośrednio na surowym (bezcechowym) sygnale,
- przeprowadzono optymalizację hiperparametrów (Optuna) oraz walidację metodami *holdout* i *k-fold*.

## Wykorzystane zbiory danych

| Zbiór | Opis |
|---|---|
| **MIMIC PERform AF** | 20-minutowe zapisy PPG/EKG 35 pacjentów OIT (19 z migotaniem przedsionków), 125 Hz — użyty jako niezależny zbiór testowy |
| **Liu Z. et al.** | Segmenty 10-sekundowe PPG, 5 typów arytmii, szpital Fuwai w Pekinie |
| **PhysioNet/CinC Challenge 2015** | 750 nagrań z 4 szpitali (USA/Europa), 250 Hz |
| **Dane syntetyczne** | 5 podzbiorów wygenerowanych symulatorem sygnałów ECG/PPG z epizodami arytmii (kontrolowane parametry: obciążenie arytmią, długość epizodów, udział przedwczesnych skurczów) |

Zbiory PhysioNet, Liu oraz dane syntetyczne posłużyły jako zbiór treningowy, a MIMIC jako niezależny zbiór testowy — celowo, aby uniknąć przecieku danych i sztucznego zawyżenia metryk.

## Przetwarzanie sygnału i ekstrakcja cech

Potok przetwarzania wstępnego: filtracja pasmowo-przepustowa (0.5–40 Hz) → resampling do jednolitej częstotliwości 100 Hz → normalizacja do przedziału [0, 1] → segmentacja na jednakowe okna czasowe → ekstrakcja cech.

Wektor cech obejmuje podstawowe miary statystyczne (średnia, mediana, odchylenie standardowe, wariancja, rozstęp międzykwartylowy) liczone w czterech dziedzinach analizy sygnału (m.in. dziedzina czasu).

## Modele

**Uczenie cechowe (klasyczne ML):** KNN, drzewo decyzyjne, las losowy, naiwny klasyfikator Bayesa, SVM, LS-SVM, XGBoost, CatBoost, LightGBM oraz sieć gęsta (Dense).

**Uczenie bezcechowe (surowy sygnał, sieci neuronowe w TensorFlow/Keras):** sieć gęsta, CNN 1D, LSTM, hybryda CNN+LSTM.

Optymalizację hiperparametrów przeprowadzono przy użyciu **Optuna** (optymalizacja bayesowska), a modele oceniano przy pomocy dokładności, swoistości, F1, nMCC oraz krzywej ROC/AUC, stosując dwie niezależne metody walidacji krzyżowej: **holdout** i **k-fold** (podział zachowujący separację pacjentów między foldami).

### Skrótowe wnioski

- Najlepsze wyniki w uczeniu cechowym uzyskały modele boostingowe (CatBoost) oraz KNN.
- W uczeniu bezcechowym najlepiej radziły sobie sieci gęste i konwolucyjne (AUC ≈ 0.85); dodanie warstw LSTM pogarszało jakość klasyfikacji.
- Optymalizacja hiperparametrów istotnie poprawiła wyniki walidacji holdout (największa poprawa dla lasu losowego).

Pełny opis metodyki, wzory, tabele wyników i dyskusję zawiera praca dostępna w [`thesis/main.pdf`](thesis/main.pdf).

## Struktura repozytorium

```
data/                # dane oraz skrypty MATLAB do ich pobierania/przygotowania (holdout, k-fold, symulator)
src/
  holdout/           # notatniki uczenia i optymalizacji hiperparametrów — walidacja holdout
  kfold/             # notatniki uczenia i optymalizacji hiperparametrów — walidacja k-fold
  holdout/utils/     # implementacja LS-SVM (kernel, konwersje, import/eksport)
doc/                 # materiały organizacyjne (założenia, prezentacja, sprawozdanie)
thesis/              # źródła LaTeX pracy magisterskiej, wykresy, main.pdf
requirements.txt      # zależności Python
```

## Uruchomienie

```bash
pip install -r requirements.txt
```

Skrypty `.m` w katalogu `data/` (uruchamiane w MATLAB/Octave) odpowiadają za pobranie, ekstrakcję cech i podział danych na foldy/zbiór holdout. Notatniki w `src/holdout/` i `src/kfold/` (`nauka_cechy.ipynb`, `nauka_bezchech.ipynb`, `optymalizacjia_hiperparametrów.ipynb`) trenują i ewaluują modele na przygotowanych wcześniej danych.

## Dokumentacja

- [`thesis/main.pdf`](thesis/main.pdf) — pełna treść pracy magisterskiej
- [`doc/plan działania/`](doc/plan%20działania/) — założenia i prezentacja seminaryjna projektu
