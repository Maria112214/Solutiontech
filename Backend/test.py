import unittest
import pandas as pd

from analise import agregar_dados, aplicar_classificacao


class TestAnalise(unittest.TestCase):

    def setUp(self):
        self.dados = pd.DataFrame({
            "tipo_solicitacao": [
                "alimentacao",
                "abrigo",
                "alimentacao"
            ],
            "distancia_solicitacao": [
                0.3,
                0.8,
                1.5
            ]
        })

    def test_agregacao(self):
        resultado = agregar_dados(
            self.dados,
            "tipo_solicitacao"
        )

        self.assertEqual(resultado["alimentacao"], 2)
        self.assertEqual(resultado["abrigo"], 1)

    def test_classificacao(self):
        resultado = aplicar_classificacao(
            self.dados,
            "distancia_solicitacao"
        )

        self.assertIn(
            "classificacao_distancia",
            resultado.columns
        )

        self.assertEqual(
            resultado.loc[0, "classificacao_distancia"],
            "curta"
        )

        self.assertEqual(
            resultado.loc[1, "classificacao_distancia"],
            "média"
        )

        self.assertEqual(
            resultado.loc[2, "classificacao_distancia"],
            "longa"
        )


if __name__ == "__main__":
    unittest.main()