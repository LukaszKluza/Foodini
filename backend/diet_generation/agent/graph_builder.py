from langgraph.graph import END, StateGraph
from langgraph.graph.state import CompiledStateGraph

from backend.diet_generation.schemas import AgentState
from backend.diet_generation.tools.planner import PlannerTool
from backend.diet_generation.tools.validator import ValidatorTool

"""Decision function, should be outside of agent class because LangGraph want callable object"""


def should_continue(state: AgentState) -> str:
    if state.validation_report == "OK":
        return "end"

    if state.correction_count >= 2:
        return "error"

    return "generate"


"""Main agent class"""


class DietAgentBuilder:
    def __init__(self, meals_per_day: int):
        self.planner = PlannerTool()
        self.validator = ValidatorTool(meals_per_day)

    def build_graph(self) -> CompiledStateGraph:
        graph_builder = StateGraph(AgentState)

        """Here functions also must to be pass as callable"""
        graph_builder.add_node("generate", self.planner.generate_plan)
        graph_builder.add_node("validate", self.validator.validate_plan)

        graph_builder.add_node(
            "error",
            lambda state: print(f"AGENT ERROR: Limit of correction was reached. Last error: {state.validation_report}"),
        )

        graph_builder.set_entry_point("generate")

        graph_builder.add_edge("generate", "validate")

        graph_builder.add_conditional_edges(
            "validate", should_continue, {"end": END, "error": "error", "generate": "generate"}
        )

        graph_builder.add_edge("error", END)

        return graph_builder.compile()
