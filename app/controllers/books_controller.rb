class BooksController < ApplicationController
  before_action :is_matching_author, only: [:edit, :update]
  before_action :set_book, only: %i[show edit update destroy]
  before_action :set_new_book, only: %i[show index tag_search]

  def create
    @new_book = current_user.books.new(book_params)
    if @new_book.save
      flash[:notice] = "本が保存されました。"
      redirect_to book_path(@new_book)
    else
      @books = Book.all
      @tags = Book.tag_counts
      render 'books/index'
    end
  end

  def show
    @comment = BookComment.new
    unless @book.view_counts.where(created_at: Time.zone.now.all_day).find_by(user_id: current_user.id)
      @view_count = ViewCount.create(:user_id => current_user.id, :book_id => @book.id)
    end
  end

  def index
    if params[:sort] == nil
      from = Time.current.ago(6.days)
      to = Time.current.end_of_day
      @books = Book.includes(:favorites).sort_by{ |book| -book.favorites.where(created_at: from...to).count }
    elsif params[:sort] == "latest"
      @books = Book.all.latest
    elsif params[:sort] == "highly_rated"
      @books = Book.all.highly_rated
    elsif params[:sort] == "highly_favorited"
      @books = Book.includes(:favorites).sort_by{ |book| -book.favorites.count}
    end

    @tags = Book.tag_counts
  end

  def tag_search
    @tags = Book.tag_counts
    if params[:sort] == nil
      from = Time.current.ago(6.days)
      to = Time.current.end_of_day
      @books = Book.tagged_with(params[:tag]).includes(:favorites).sort_by{ |book| -book.favorites.where(created_at: from...to).count }
    elsif params[:sort] == "latest"
      @books = Book.tagged_with(params[:tag]).latest
    elsif params[:sort] == "highly_rated"
      @books = Book.tagged_with(params[:tag]).highly_rated
    elsif params[:sort] == "highly_favorited"
      @books = Book.tagged_with(params[:tag]).includes(:favorites).sort_by{ |book| -book.favorites.count}
    end
  end

  def edit; end

  def update
    if @book.update(book_params)
      redirect_to book_path(@book)
      flash[:notice] = '本が更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @book.destroy
    flash[:danger] = '本が削除されました。'
    redirect_to books_path
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def set_new_book
    @new_book = Book.new
  end

  def book_params
    params.require(:book).permit(:title, :body, :image, :star, :tag_list)
  end

  def is_matching_author
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end
end
