class BooksController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :set_wooden_background, only: [:index, :search, :show]
  before_action :set_small_book_block, only: [:index, :search]
  before_action :set_big_book_block, only: [:show] 
    
  def index
    @books = Book.all
  end
    
  def new
    @book = Book.new 
  end 
    
  def create
    @book = Book.new(book_params)
    @book.author_id = Author.find_or_create_by(name: book_params[:author_id]).id

    if @book.save
      flash[:success] = "Một sách mới đã được tạo."
      redirect_to books_path
    else
      flash[:error] = @book.errors.full_messages.to_sentence
      redirect_to :back 
    end 
  end 
    
  def edit
    @book = Book.find(params[:id])
  end
    
  def update
    @book = Book.find(params[:id])
    
    @book.author_id = Author.find_or_create_by(name: book_params[:author_id]).id
    @book.category_id = book_params[:category_id]
    @book.title = book_params[:title]
    @book.isbn = book_params[:isbn]
    @book.description = book_params[:description]
    @book.image_url = book_params[:image_url]
    
    if @book.save
      flash[:success] = "Một sách đã cập nhật."
      redirect_to books_path
    else
      flash[:error] = "Oh, không cập nhật được sách"
      flash[:error] = @book.errors.full_messages.to_sentence
      redirect_to :back 
    end 
  end
    
  def destroy
    @book = Book.find(params[:id])
    @book.destroy 
    flash[:success] = "Một sách đã xoá."
    redirect_to books_path
  end 
    
  def search
    @books = Book.where(["title_downcase ILIKE ?","%#{params[:q].mb_chars.downcase.to_s}%"])

    client = Goodreads.new
    @books_from_goodreads = client.search_books(params[:q])
  end

  def show
    @book = Book.find(params[:id])
  end

private 
  def book_params
    params.require(:book).permit(:title, :author_id, :description, :isbn, :category_id, :image_url)
  end 

end
