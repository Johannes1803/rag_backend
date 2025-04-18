from pathlib import Path
from typing import Generator, List, Union

from hayhooks import (
    BasePipelineWrapper,
    get_last_user_message,
    log,
    streaming_generator,
)
from haystack import Pipeline


class PipelineWrapper(BasePipelineWrapper):
    def setup(self) -> None:
        pipeline_yaml = (Path(__file__).parent / "llm_only.yaml").read_text()
        self.pipeline = Pipeline.loads(pipeline_yaml)

    def run_api(self, question: str) -> str:
        log.trace(f"Running pipeline with question: {question}")
        result = self.pipeline.run({"prompt_builder": {"query": question}})
        return result["generator"]["replies"][0]

    def run_chat_completion(self, model: str, messages: List[dict], body: dict) -> Union[str, Generator]:
        log.trace(f"Running pipeline with model: {model}, messages: {messages}, body: {body}")

        question = get_last_user_message(messages)
        log.trace(f"Question: {question}")

        # Streaming pipeline run, will return a generator
        return streaming_generator(
            pipeline=self.pipeline,
            pipeline_run_args={"prompt_builder": {"query": question}},
        )
