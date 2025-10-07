#include <boost/asio.hpp>
#include <boost/beast.hpp>
#include <iostream>
#include <string>

namespace asio = boost::asio;
namespace beast = boost::beast;
namespace http = beast::http;

using tcp = asio::ip::tcp;

class HttpServer {
public:
    HttpServer(asio::io_context& io_context, short port)
        : acceptor_(io_context, tcp::endpoint(tcp::v4(), port)) {
        start_accept();
    }

private:
    void start_accept() {
        auto socket = std::make_shared<tcp::socket>(acceptor_.get_executor());
        acceptor_.async_accept(*socket, [this, socket](boost::system::error_code ec) {
            if (!ec) {
                handle_request(socket);
            }
            start_accept();
        });
    }

    void handle_request(std::shared_ptr<tcp::socket> socket) {
        auto buffer = std::make_shared<beast::flat_buffer>();
        auto request = std::make_shared<http::request<http::string_body>>();

        http::async_read(*socket, *buffer, *request,
            [this, socket, buffer, request](boost::system::error_code ec, std::size_t) {
                if (!ec) {
                    send_response(socket, request);
                }
            });
    }

    void send_response(std::shared_ptr<tcp::socket> socket, 
                      std::shared_ptr<http::request<http::string_body>> request) {
        auto response = std::make_shared<http::response<http::string_body>>();

        if (request->target() == "/healthcheck" || request->target() == "/") {
            // Healthcheck handler
            response->result(http::status::ok);
            response->set(http::field::content_type, "application/json");
            response->body() = R"({"status": "ok", "message": "Server is running"})";
        } else {
            // 404 handler
            response->result(http::status::not_found);
            response->set(http::field::content_type, "text/plain");
            response->body() = "Not Found";
        }

        response->prepare_payload();
        response->set(http::field::server, "Boost Server");

        http::async_write(*socket, *response,
            [socket, response](boost::system::error_code ec, std::size_t) {
                if (!ec) {
                    socket->shutdown(tcp::socket::shutdown_send);
                }
            });
    }

    tcp::acceptor acceptor_;
};

int main() {
    try {
        asio::io_context io_context;
        short port = 8080;

        HttpServer server(io_context, port);
        
        std::cout << "Server started on port " << port << std::endl;
        std::cout << "Healthcheck available at: http://localhost:" << port << "/healthcheck" << std::endl;

        io_context.run();
    } catch (std::exception& e) {
        std::cerr << "Exception: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
