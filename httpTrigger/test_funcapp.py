from visitorCounter import main
import unittest
import azure.functions as func
from unittest.mock import patch, MagicMock
from azure.core.exceptions import HttpResponseError

# Still not working effectively
class TestHttpTrigger(unittest.TestCase):
    
    @patch("visitorCounter.TableClient")
    def test_main_with_existing_entity(self, mock_table_client):
        # Mock the get_entity method to simulate an existing entity
        mock_table_client.get_entity.return_value = False

        # Create an instance of HttpRequest with the necessary parameters
        req = func.HttpRequest(
            method='GET',
            url='/api/visitorCounter',
            body=""
        )
       
        # Call the main function with the mocked func.HttpRequest
        response = main(req, messageJSON=None)
        print(response.get_body(), response.status_code)
        
        # Assert that the response is as expected
        # self.assertEqual(response.get_body(), b'5')
        self.assertEqual(response.status_code, 200)

    # @patch("visitorCounter.TableClient")
    # def test_main_without_existing_entity(self, mock_table_client):
    #     # Mock the get_entity method to simulate a non-existing entity
    #     mock_table_client.return_value.get_entity.side_effect = HttpResponseError(response=MagicMock(status_code=404))

    #     # Create an instance of func.HttpRequest with the necessary parameters
    #     req = func.HttpRequest(
    #         method='GET',
    #         body=None,
    #         url='/api/visitorCounter',
    #     )

    #     # Call the main function with the mocked func.HttpRequest
    #     response = main(req, messageJSON=None)

    #     # Assert that the response is as expected
    #     self.assertEqual(response.get_body(), b'1')
    #     self.assertEqual(response.status_code, 200)

    # @patch("visitorCounter.TableClient")
    # def test_main_with_invalid_data(self, mock_table_client):
    #     # Mock the get_entity method to simulate an invalid data scenario
    #     mock_table_client.return_value.get_entity.return_value = {"NumberOfVisitors": "invalid_data"}

    #     # Create an instance of HttpRequest with the necessary parameters
    #     req = func.HttpRequest(
    #         method='GET',
    #         body=None,
    #         url='/api/visitorCounter',
    #     )

    #     # Call the main function with the mocked HttpRequest
    #     response = main(req, messageJSON=None)

    #     # Assert that the response is as expected
    #     self.assertEqual(response.get_body(), b'4XX')
    #     self.assertEqual(response.status_code, 404)

if __name__ == '__main__':
    unittest.main()