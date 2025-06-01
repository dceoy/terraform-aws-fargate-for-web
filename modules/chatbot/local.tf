locals {
  create_chatbot = var.chatbot_slack_workspace_id != null && var.chatbot_slack_channel_id != null ? true : false
}
