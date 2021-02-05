require 'telegram/bot'
require_relative 'BashQuote'

token = 'token'

def generate_message
  bq = BashQuote.new
  bq.run()
  res = bq.get_id + "\n\n" + bq.get_body + "\n\n" + "Source: " + bq.get_link
  return res
end

def generate_all
  bq = BashQuote.new
  bq.run()
  return bq.get_id, bq.get_body, bq.get_link
end

Telegram::Bot::Client.run(token) do |bot|
  File.write('./log', 'The bot has started at ' + (Time.now).to_s + "\n\n")

  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      File.write('./log', "User #{message.from.username} has used an inlineQuery at " + (Time.now).to_s + "\n", mode: 'a')

      id, body, link = generate_all
      random_res_id = rand(10000)

      results = [
        [random_res_id, id, id + "\n\n" + body + "\n\n" + "Source: " + link]
      ].map do |arr|
        Telegram::Bot::Types::InlineQueryResultArticle.new(
          id: arr[0],
          title: arr[1],
          input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(
            message_text: arr[2],
            disable_web_page_preview: true)
        )
      end

      bot.api.answer_inline_query(inline_query_id: message.id, cache_time: 0, results: results)
    
    when Telegram::Bot::Types::Message
      File.write('./log', "User #{message.from.username} has written a message at " + (Time.now).to_s + "\n", mode: 'a')
      button = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [%w[One_more]])
      
      bot.api.send_message(chat_id: message.chat.id, text: "Держи цитатку, #{message.from.first_name}:\n")
      bot.api.send_message(chat_id: message.chat.id, disable_web_page_preview: true, text: generate_message, reply_markup: button)
    end
  end
end
