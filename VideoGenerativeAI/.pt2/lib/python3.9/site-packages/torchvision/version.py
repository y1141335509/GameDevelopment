__version__ = '0.16.1'
git_version = 'fdea156b80780313d6248847ab16d5d68eef9679'
from torchvision.extension import _check_cuda_version
if _check_cuda_version() > 0:
    cuda = _check_cuda_version()
