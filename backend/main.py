from fastapi import FastAPI
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from langchain_core.messages import HumanMessage

# Import the compiled agent executor from the 'app' package
from app.agent import agent_executor, AgentState

app = FastAPI(title="HR Agentic Application API")

# Add CORS middleware to allow requests from the frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

@app.get("/", tags=["Root"])
async def read_root():
    return {"message": "Welcome to the HR Agentic Application API!"}

@app.post("/chat", tags=["Agent"])
async def chat_with_agent(query: str):
    """
    Receives a user query and returns the agent's response.
    """
    try:
        # Define the initial state for the graph
        initial_state: AgentState = {"messages": [HumanMessage(content=query)]}
        
        # Invoke the agent graph asynchronously
        response_stream = agent_executor.astream(initial_state)
        
        final_response = None
        async for event in response_stream:
            if "agent" in event:
                # The final message from the agent after the loop
                final_response = event["agent"]["messages"][-1]

        if final_response:
             response_text = final_response.content
        else:
            response_text = "The agent could not process the request."

        return JSONResponse(content={"response": response_text})
    except Exception as e:
        # Return a more descriptive error to the frontend
        print(f"Error during agent invocation: {e}") # Log error to backend console
        return JSONResponse(content={"error": f"Agent Error: {e}"}, status_code=500)