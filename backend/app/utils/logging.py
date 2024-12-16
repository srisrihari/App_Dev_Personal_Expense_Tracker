import logging
import os
from logging.handlers import RotatingFileHandler

class DetailedFormatter(logging.Formatter):
    def format(self, record):
        record.pathname = record.pathname.split('/')[-1]
        return super().format(record)

def setup_logging():
    # Create logs directory if it doesn't exist
    logs_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 'logs')
    os.makedirs(logs_dir, exist_ok=True)

    # Configure logging
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)

    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_formatter = logging.Formatter('%(levelname)s: %(message)s')
    console_handler.setFormatter(console_formatter)
    logger.addHandler(console_handler)

    # File handler for detailed logs
    detailed_handler = RotatingFileHandler(
        os.path.join(logs_dir, 'detailed.log'),
        maxBytes=1024*1024,  # 1MB
        backupCount=5
    )
    detailed_handler.setLevel(logging.DEBUG)
    detailed_formatter = DetailedFormatter(
        '%(asctime)s - %(name)s - %(levelname)s - [%(pathname)s:%(lineno)d] - %(message)s'
    )
    detailed_handler.setFormatter(detailed_formatter)
    logger.addHandler(detailed_handler)

    # File handler for registration logs
    registration_handler = RotatingFileHandler(
        os.path.join(logs_dir, 'registration.log'),
        maxBytes=1024*1024,  # 1MB
        backupCount=5
    )
    registration_handler.setLevel(logging.INFO)
    registration_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    registration_handler.setFormatter(registration_formatter)
    logger.addHandler(registration_handler)

    return logger
