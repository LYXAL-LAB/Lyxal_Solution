from unittest import TestCase, main
from lyxalml.model_templates.torch.torch_linear import train_model
from lyxalml.rust_adapter import RustAdapter
from lyxalml.surml_file import LyxMlFile
from lyxalml.engine import Engine
import shutil


class TestRustAdapter(TestCase):

    def setUp(self):
        self.model, self.x = train_model()
        self.file = LyxMlFile(model=self.model, name="linear", inputs=self.x, engine=Engine.PYTORCH)

    def tearDown(self):
        shutil.rmtree(".surmlcache")

    def test_basic_store(self):
        # pass
        self.file.add_column(name="x")
        # self.file.save(path="./unit_test.surml")


if __name__ == '__main__':
    main()
