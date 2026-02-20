include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "alarm" {
  config_path = "../alarm"
  mock_outputs = {
    alarm_sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:example-topic"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  sns_topic_arns = [dependency.alarm.outputs.alarm_sns_topic_arn]
}

terraform {
  source = "${get_repo_root()}/modules/chatbot"
}
