from airflow import DAG
from datetime import datetime, timedelta, date
from airflow.operators.dummy_operator import DummyOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.utils.task_group import TaskGroup
from airflow.models import Variable



DB_CONN = 'gp_std7_170'
DB_SCHEMA = 'std7_170'
DB_PROC_LOAD = 'f_load_full'
FULL_LOAD_TABLES = ['chanel', 'price', 'product', 'region']
FULL_LOAD_FILES = {'chanel': 'chanel', 'price': 'price', 'product': 'product', 'region': 'region'}
MD_TABLE_LOAD_QUERY = f"select {DB_SCHEMA}.{DB_PROC_LOAD}(%(tab_name)s, %(file_name)s);"

LOAD_PART_TABLE = "SELECT std7_170.f_load_simple_partition('std7_170.sales', 'date', '2021-05-01', '2021-06-01', 'gp.sales', 'intern', 'intern'); SELECT std7_170.f_load_simple_partition('std7_170.plan', 'date', '2021-05-01', '2021-06-01', 'gp.plan', 'intern', 'intern');"

DATA_MART = "SELECT std7_170.f_load_mart('202105');"

default_args = {
    'depends_on_past': False,
    'owner': 'std7_170',
    'start_date': datetime(2024, 9, 20),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    "std7_170_main_dag",
    max_active_runs=3,
    schedule_interval=None,
    default_args=default_args,
    catchup=False,
) as dag:
    
    task_start = DummyOperator(task_id="start")
    
    task_delta_part_tables = PostgresOperator(task_id="load_delta_part_table",
                                              postgres_conn_id=DB_CONN,
                                              sql=LOAD_PART_TABLE
                                             )
    
    with TaskGroup("full_load") as task_full_load_tables:
        for table in FULL_LOAD_TABLES:
            task = PostgresOperator(task_id=f"load_table_{table}",
                                    postgres_conn_id=DB_CONN,
                                    sql=MD_TABLE_LOAD_QUERY,
                                    parameters={'tab_name':f'{DB_SCHEMA}.{table}', 'file_name':FULL_LOAD_FILES[table]}
                                   )
                                    
    task_data_mart = PostgresOperator(task_id="create_data_mart",
                                      postgres_conn_id=DB_CONN,
                                      sql=DATA_MART
                                     )    
    
    task_end = DummyOperator(task_id="end")
    
    
    task_start >> task_delta_part_tables >> task_full_load_tables >> task_data_mart >> task_end
