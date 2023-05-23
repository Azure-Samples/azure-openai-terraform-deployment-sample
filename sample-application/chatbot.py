"""
create a ".env" file with the following:
OPENAI_API_TYPE = azure
OPENAI_API_VERSION = 2023-03-15-preview
OPENAI_API_BASE = 'https://eastus.api.cognitive.microsoft.com/' # Replace with the URL of an Azure OpenAI
OPENAI_API_KEY = '' # Replace with the corresponding API key

to run the file:
streamlit run chatbot.py
"""
import logging
import sys

logging.basicConfig(stream=sys.stdout, level=logging.INFO) # logging.DEBUG for more verbose output
#logging.getLogger().addHandler(logging.StreamHandler(stream=sys.stdout))
logging.getLogger("llama_index").setLevel(logging.DEBUG)


import os
import streamlit as st
from llama_index import download_loader, SimpleDirectoryReader
from llama_index.node_parser import SimpleNodeParser
from llama_index import (
    LLMPredictor,
    GPTVectorStoreIndex,
    PromptHelper,
    ServiceContext,
    StorageContext,
    load_index_from_storage,
)
from llama_index.logger import LlamaLogger

from langchain.chat_models import AzureChatOpenAI
from langchain.embeddings import OpenAIEmbeddings
from llama_index import LangchainEmbedding

from dotenv import load_dotenv
from dotenv import dotenv_values

load_dotenv()
config = dotenv_values(".env")

doc_path = "./data/"
index_file = "index.json"

if "response" not in st.session_state:
    st.session_state.response = ""

# save current file name to avoid reprocessing document
if "current_file" not in st.session_state:
    st.session_state.current_file = None


def send_click():
    query_engine = index.as_query_engine()
    # answer = query_engine.query(st.session_state.prompt)
    # st.session_state.response = answer.get_formatted_sources()
    st.session_state.response = query_engine.query(st.session_state.prompt)
    st.session_state.lamalogs = service_context.llama_logger.get_logs()


index = None
st.title("Azure OpenAI Doc Chatbot")

sidebar_placeholder = st.sidebar.container()

uploaded_file = st.file_uploader("Choose a file")

llm = AzureChatOpenAI(
    deployment_name="gpt-35-turbo",
    model_kwargs={
        "api_key": config["OPENAI_API_KEY"],
        "api_base": config["OPENAI_API_BASE"],
        "api_type": config["OPENAI_API_TYPE"],
        "api_version": config["OPENAI_API_VERSION"],
    },
)

embedding_llm = LangchainEmbedding(
    OpenAIEmbeddings(
        model="text-embedding-ada-002",
        deployment="text-embedding-ada-002",
        openai_api_key=config["OPENAI_API_KEY"],
        openai_api_base=config["OPENAI_API_BASE"],
        openai_api_type=config["OPENAI_API_TYPE"],
        openai_api_version=config["OPENAI_API_VERSION"],
    ),
    embed_batch_size=1,
)


# llama_index provides LLMPredictor
llm_predictor = LLMPredictor(llm=llm)
max_input_size = 4096
num_output = 256
max_chunk_overlap = 20
prompt_helper = PromptHelper(max_input_size, num_output, max_chunk_overlap)

llama_logger = LlamaLogger()

# llama_index provides ServiceContext
service_context = ServiceContext.from_defaults(
    llm_predictor=llm_predictor,
    prompt_helper=prompt_helper,
    embed_model=embedding_llm,
    chunk_size_limit=1000,
    llama_logger=llama_logger
)

if uploaded_file is not None and uploaded_file.name != st.session_state.current_file:
    with st.spinner('Ingesting the file..'):
        doc_files = os.listdir(doc_path)
        for doc_file in doc_files:
            os.remove(doc_path + doc_file)

        bytes_data = uploaded_file.read()
        with open(f"{doc_path}{uploaded_file.name}", "wb") as f:
            f.write(bytes_data)

        #SimpleDirectoryReader = download_loader("SimpleDirectoryReader")

        loader = SimpleDirectoryReader(doc_path, recursive=True, exclude_hidden=True)
        documents = loader.load_data()
        sidebar_placeholder.header("Current Processing Document:")
        sidebar_placeholder.subheader(uploaded_file.name)
        sidebar_placeholder.write(documents[0].get_text()[:500] + "...")

        index = GPTVectorStoreIndex.from_documents(
            documents, service_context=service_context
        )

        index.set_index_id("vector_index")
        index.storage_context.persist(index_file)
        st.session_state.current_file = uploaded_file.name
        st.session_state.response = ""  # clean up the response when new file is uploaded
    st.success('Done!')

elif os.path.exists(index_file):
    storage_context = StorageContext.from_defaults(persist_dir=index_file)
    index = load_index_from_storage(
        storage_context, index_id="vector_index", service_context=service_context
    )

    SimpleDirectoryReader = download_loader("SimpleDirectoryReader")
    loader = SimpleDirectoryReader(doc_path, recursive=True, exclude_hidden=True)
    documents = loader.load_data()
    doc_filename = os.listdir(doc_path)[0]
    sidebar_placeholder.header("Current Processing Document:")
    sidebar_placeholder.subheader(doc_filename)
    sidebar_placeholder.write(documents[0].get_text()[:500] + "...")

if index != None:
    st.text_input("Ask something: ", key="prompt", on_change=send_click)
    st.button("Send", on_click=send_click)
    if st.session_state.response:
        st.subheader("Response: ")
        st.success(st.session_state.response, icon="🤖")
        st.subheader("Debug information: ")
        st.write("This is the formatted prompt template:")
        st.code(st.session_state.lamalogs[0]['formatted_prompt_template'])
        st.write("This is the initial response:")
        st.code(st.session_state.lamalogs[1]['initial_response'])

