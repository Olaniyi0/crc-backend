import azure.functions as func
from os import environ
from azure.data.tables import TableClient, UpdateMode


def main(req: func.HttpRequest, messageJSON) -> func.HttpResponse:

    connection_string = environ.get("RESUMEDB_CONNECTION_STRING")
    table_name = environ.get("DATABASE_TABLE_NAME")
    table_service = TableClient.from_connection_string(conn_str=connection_string, table_name=table_name)

    try:
        # Tries to get number of visitors if already exist
        num_of_visitors = int(table_service.get_entity(partition_key="visitorsCount", row_key="1")["NumberOfVisitors"]) + 1
    except Exception as e:
        data = {
        "NumberOfVisitors": 1,
        "PartitionKey": "visitorsCount",
        "RowKey": "1"
        }
        table_service.create_entity(entity=data)
        return func.HttpResponse(f"{data['NumberOfVisitors']}")
    else:
        table_service.update_entity(entity={
            "NumberOfVisitors": num_of_visitors,
            "PartitionKey": "visitorsCount",
            "RowKey": "1"
            }, mode=UpdateMode.Replace)

        return func.HttpResponse(f"{num_of_visitors}")
        
  
#changedg