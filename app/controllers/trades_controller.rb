class TradesController < ApplicationController
  before_action :set_trade, only: [:show, :edit, :update, :destroy]

  def index
    # find @trades that only belong to a particular instrument AND a trader
    if trader_id = params[:trader_id] and instrument_id = params[:instrument_id]
      @trader = Trader.find_by(id: trader_id)
      @instrument = Instrument.find_by(id: instrument_id)
      @trades = Trade.where(trader_id: trader_id, instrument_id: instrument_id)
    elsif id = params[:trader_id]
      @trader = Trader.find_by(id: id)
      @trades = @trader.trades
    elsif id = params[:instrument_id]
      @instrument = Instrument.find_by(id: id)
      @trades = @instrument.trades
    else
      @trades = Trade.all
    end

    respond_to do |format|
      format.html {render :index}
      format.json {render json: @trades}
    end
  end

  def show
    if !!@trade
      @comment = @trade.comments.build
      respond_to do |format|
        format.html {render :show}
        format.json {render json: @trade}
      end
    else
      render json: {error: "This trade has been deleted or hasn't been created yet.", id: params[:id]}
    end
  end

  def new
    @trade = Trade.new
  end

  def create
    @trade = current_trader.trades.build(trade_params)
    if @trade.save
      redirect_to trader_trade_path(current_trader, @trade)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @trade.trader == current_trader
      if @trade.update(trade_params)
        flash[:notice] = "Trade edited successfully."
        redirect_to trade_path(@trade)
      else
        render :edit
      end
    else
      flash[:error] = "You are not authorized to edit this trade!"
      redirect_to :index
    end
  end

  def destroy
    if @trade.trader == current_trader
      @trade.delete
      flash[:notice] = "Trade deleted."
    else
      flash[:error] = "You are not authorized to delete this trade!"
    end
    redirect_to trader_trades_path(current_trader)
  end

  def best
    @trade = Trade.most_profitable
    render :show
  end

  def worst
    @trade = Trade.least_profitable
    render :show
  end


  private
    def set_trade
      @trade = Trade.find_by(id: params[:id])
    end

    def trade_params
      params.require(:trade).permit(:direction, :entry, :exit, :quantity, :notes, :instrument_id, instrument_attributes: [:symbol])
    end

end
