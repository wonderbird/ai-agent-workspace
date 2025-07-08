from synchronize.main import main


def test_main():
    assert main() == "Syncing repositories to remote server..."
