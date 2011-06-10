<!-- 

Version: 0.1.1

Copyright (c) 2011, PacketFront International AB
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of PacketFront International AB nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" indent="no" doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN" />

  <!-- Repeat character(s) specified number of times -->
  <xsl:template name="repeat">
    <xsl:param name="count"/>
    <xsl:param name="char"/>
    <xsl:if test="$count > 0">
      <xsl:value-of select="$char"/>
      <xsl:call-template name="repeat">
	<xsl:with-param name="count" select="$count - 1"/>
	<xsl:with-param name="char" select="$char"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <!-- Quote function, since xsltproc only supports XSLT 1.0 functions.
       Supports up to two chars to quote. -->
  <xsl:template name="quote">
    <xsl:param name="string"/>
    <xsl:param name="char"/>
    <xsl:param name="char2" select="''"/>
    <xsl:choose>
      <xsl:when test="contains($string,$char)">
	<xsl:value-of select="concat(substring-before($string,$char),'\',$char)"/>
	<xsl:call-template name="quote">
	  <xsl:with-param name="string" select="substring-after($string,$char)"/>
	  <xsl:with-param name="char" select="$char"/>
	  <xsl:with-param name="char2" select="$char2"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$char2 != '' and contains($string,$char2)">
	<xsl:value-of select="concat(substring-before($string,$char2),'\',$char2)"/>
	<xsl:call-template name="quote">
	  <xsl:with-param name="string" select="substring-after($string,$char2)"/>
	  <xsl:with-param name="char" select="$char"/>
	  <xsl:with-param name="char2" select="$char2"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Special reference handling for a sect2 with title "See also". -->
  <xsl:template name="seealso">
    <xsl:param name="content"/>
    <xsl:if test="$content != ''">
      <xsl:text>&lt;&lt;</xsl:text>
      <xsl:choose>
	<xsl:when test="substring-before(translate(normalize-space($content),'&#160;',' '),' on') = ''">
	  <xsl:value-of select="translate(normalize-space($content),'&#160;',' ')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="substring-before(translate(normalize-space($content),'&#160;',' '),' on')"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text>&gt;&gt;</xsl:text>
    </xsl:if>
  </xsl:template>






  <xsl:template match="chapter/title">
      <xsl:value-of select="."/>
      <xsl:text>&#10;</xsl:text>
      <xsl:call-template name="repeat">
	<xsl:with-param name="count" select="string-length(.)"/>
	<xsl:with-param name="char" select="'='"/>
      </xsl:call-template>
      <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="sect1/title">
    <xsl:text>/* asciidoc&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&#10;</xsl:text>
    <xsl:call-template name="repeat">
      <xsl:with-param name="count" select="string-length(.)"/>
      <xsl:with-param name="char" select="'-'"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="sect2title">
    <xsl:param name="title"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select="$title"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:call-template name="repeat">
      <xsl:with-param name="count" select="string-length($title)"/>
      <xsl:with-param name="char" select="'~'"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="sect2/title">
    <xsl:call-template name="sect2title">
      <xsl:with-param name="title" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="sect3/title">
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&#10;</xsl:text>
    <xsl:call-template name="repeat">
      <xsl:with-param name="count" select="string-length(.)"/>
      <xsl:with-param name="char" select="'^'"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>


  <xsl:template match="sect2">
    <xsl:choose>
      <xsl:when test="title = 'See also' or title = 'See Also'">

	<xsl:call-template name="sect2title">
	  <xsl:with-param name="title" select="title"/>
	</xsl:call-template>

	<xsl:text>&#10;</xsl:text>
	
	<xsl:for-each select="para">
	  <xsl:call-template name="seealso">
	    <xsl:with-param name="content" select="."/>
	  </xsl:call-template>
	  <xsl:text>&#10;</xsl:text>
	</xsl:for-each>
	<xsl:text>&#10;</xsl:text>
	
      </xsl:when>
      <xsl:otherwise>
	
	<xsl:apply-templates/>

      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>




  <xsl:template match="command/text()[1]">
    <xsl:text>*</xsl:text>
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
    <xsl:text>* </xsl:text>
  </xsl:template>

  <xsl:template match="command/text()[last()]">
    <xsl:text>*</xsl:text>
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
    <xsl:text>*</xsl:text>
  </xsl:template>

  <xsl:template match="command/text()[position()>1]">
    <xsl:text> *</xsl:text>
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
    <xsl:text>* </xsl:text>
  </xsl:template>


  <xsl:template match="filename/text()[1]">
    <xsl:text>'</xsl:text>
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
    <xsl:text>' </xsl:text>
  </xsl:template>

  <xsl:template match="filename/text()[last()]">
    <xsl:text>'</xsl:text>
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
    <xsl:text>'</xsl:text>
  </xsl:template>

  <xsl:template match="filename/text()[position()>1]">
    <xsl:text> '</xsl:text>
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
    <xsl:text>' </xsl:text>
  </xsl:template>


  <xsl:template match="literal/text()[1]">
    <xsl:text>+</xsl:text>
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
    <xsl:text>+ </xsl:text>
  </xsl:template>

  <xsl:template match="literal/text()[last()]">
    <xsl:text>+</xsl:text>
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
    <xsl:text>+</xsl:text>
  </xsl:template>

  <xsl:template match="literal/text()[position()>1]">
    <xsl:text> +</xsl:text>
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
    <xsl:text>+ </xsl:text>
  </xsl:template>

  <xsl:template match="literallayout/text()|programlisting/text()">
    <xsl:text>&#10;[listing]&#10;</xsl:text>
    <xsl:call-template name="repeat">
      <xsl:with-param name="count" select="17"/>
      <xsl:with-param name="char" select="'.'"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&#10;</xsl:text>
    <xsl:call-template name="repeat">
      <xsl:with-param name="count" select="17"/>
      <xsl:with-param name="char" select="'.'"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="para/text()">
    <xsl:value-of select="translate(normalize-space(.),'&#160;',' ')"/>
  </xsl:template>

  <xsl:template match="para">
    <xsl:apply-templates />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>



  <xsl:template match="itemizedlist">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="listitem"/>
  </xsl:template>

  <xsl:template match="itemizedlist/listitem">
    <xsl:text>- </xsl:text>
    <xsl:apply-templates />
    <xsl:text>&#10;</xsl:text>
  </xsl:template>




  <xsl:template match="table">
    <xsl:value-of select="translate(normalize-space(title),'&#160;',' ')"/>
    <xsl:text>&#10;&#10;</xsl:text>
    <xsl:apply-templates select="tgroup"/>
  </xsl:template>

  <xsl:template match="tgroup">
    <xsl:text>&#10;[options="header"]&#10;</xsl:text>
    <xsl:text>|</xsl:text>
    <xsl:call-template name="repeat">
      <xsl:with-param name="count" select="50"/>
      <xsl:with-param name="char" select="'='"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="thead"/>
    <xsl:apply-templates select="tbody"/>
    <xsl:text>|</xsl:text>
    <xsl:call-template name="repeat">
      <xsl:with-param name="count" select="50"/>
      <xsl:with-param name="char" select="'='"/>
    </xsl:call-template>
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tgroup/thead">
    <xsl:for-each select="row">
      <xsl:for-each select="entry">
	<xsl:text>|</xsl:text>
	<xsl:call-template name="quote">
	  <xsl:with-param name="string" select="translate(normalize-space(.),'&#160;',' ')"/>
	  <xsl:with-param name="char" select="'|'"/>
	</xsl:call-template>
      </xsl:for-each>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tgroup/tbody">
    <xsl:for-each select="row">
      <xsl:for-each select="entry">
	<xsl:text>|</xsl:text>
	<xsl:call-template name="quote">
	  <xsl:with-param name="string" select="translate(normalize-space(.),'&#160;',' ')"/>
	  <xsl:with-param name="char" select="'|'"/>
	</xsl:call-template>
      </xsl:for-each>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>


  <!-- graphic tag currently only supported within <figure> tag. -->
  <xsl:template match="figure">
    <xsl:text>&#10;.</xsl:text>
    <xsl:value-of select="translate(normalize-space(title),'&#160;',' ')"/>
    <xsl:text>&#10;image::</xsl:text>
    <xsl:choose>
      <xsl:when test="graphic/@fileref != ''">
	<xsl:value-of select="graphic/@fileref"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="unparsed-entity-uri(graphic/@entityref)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>[</xsl:text>
    <xsl:value-of select="translate(normalize-space(title),'&#160;',' ')"/>
    <xsl:text>]</xsl:text>
  </xsl:template>



  <!-- Documents from FrameMaker has <?FM MARKER [Index] text?> tags, convert
       them to indexterm. -->
  <xsl:template match="processing-instruction('FM')">
    <xsl:if test="substring-after(translate(normalize-space(.),'&#160;',' '),'MARKER [Index] ') != ''">
      <xsl:text>(((</xsl:text>
      <xsl:value-of select="substring-after(translate(normalize-space(.),'&#160;',' '),'MARKER [Index] ')"/>
      <xsl:text>)))</xsl:text>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>

