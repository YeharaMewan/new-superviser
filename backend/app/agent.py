from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from langgraph.graph import StateGraph, END
from langgraph.prebuilt import ToolNode
from typing import TypedDict, Annotated
import operator

from .tools import all_tools
from langchain_core.messages import AnyMessage, SystemMessage, HumanMessage

# 1. Define the Agent's State
class AgentState(TypedDict):
    messages: Annotated[list[AnyMessage], operator.add]

# 2. Define the Agent's Logic (The "Thinker" Node)
def agent_node(state: AgentState):
    response = agent_runnable.invoke(state)
    return {"messages": [response]}

# 3. Define the Tool Node (The "Actor")
tool_node = ToolNode(all_tools)

# 4. Define the conditional logic to route between nodes
def should_continue(state: AgentState) -> str:
    last_message = state['messages'][-1]
    if last_message.tool_calls:
        return "continue_to_tools"
    return "end_conversation"

# --- BUILD THE GRAPH ---

llm = ChatOpenAI(model="gpt-4o", temperature=0)

# A more detailed system prompt to make the agent smarter
system_prompt = (
    "You are a highly intelligent and friendly HR Assistant for a company. "
    "Your primary role is to assist employees with their HR-related inquiries in Sinhala or English."
    "1.  **Analyze the User's Request:** Carefully understand what the user is asking. Is it a question about policy, a request for data, or an action like applying for leave?\n"
    "2.  **Select the Right Tool:** You have a set of tools to help you. Choose the best one for the job:\n"
    "    - Use `search_hr_policies` for questions about company rules, leave policy, work-from-home policy, etc.\n"
    "    - Use `request_leave` ONLY when a user explicitly asks to apply for leave.\n"
    "    - For ANY other question that requires information from the database (like attendance, employee lists, department details, who is on leave), use the `answer_database_question` tool. Pass the user's full, original question to this tool.\n"
    "3.  **Formulate the Answer:** Based on the tool's output, provide a clear, concise, and friendly answer to the user. Do not just output raw data.\n"
    "4.  **Clarify if Needed:** If you cannot understand the request or if the tools return an error, don't guess. Ask the user for clarification in a polite manner."
)

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        MessagesPlaceholder(variable_name="messages"),
    ]
)

llm_with_tools = llm.bind_tools(all_tools)
agent_runnable = prompt | llm_with_tools

graph = StateGraph(AgentState)
graph.add_node("agent", agent_node)
graph.add_node("tools", tool_node)
graph.set_entry_point("agent")
graph.add_conditional_edges(
    "agent",
    should_continue,
    {"continue_to_tools": "tools", "end_conversation": END}
)
graph.add_edge("tools", "agent")
agent_executor = graph.compile()